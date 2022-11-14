//
//  EventHandler.m
//  EndpointExtension
//
//  Created by Виктор Семенов on 12.11.2022.
//

#import "EventHandler.h"
#include <pwd.h>

@interface EventHandler ()

@property NSDateFormatter *dateFormatter;

@end

@implementation EventHandler

- (instancetype)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  self.dateFormatter = [NSDateFormatter new];
  self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
  return self;
}

- (NSDictionary *)handleMessage:(es_message_t *)message {
  NSString *pid = [self getPID:message];
  NSString *username = [self getUsername:message];
  NSString *sourceFilePath = [self extractSourceFilePath:message];
  NSString *destFilePath = [self extractDestinationFilepath:message];
  NSString *time = [_dateFormatter stringFromDate: [NSDate new]];
  NSString *eventType = [self getEventType:message];
  NSString *childPID = [self getChildPID:message];
  NSString *execImage = [self getExecImage:message];
  NSString *exitStatus = [self getExitStatus:message];
  NSNumber *nsec = [self getTimestamp:message];
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  if (pid) {
    [dictionary setValue:pid forKey:@"pid"];
  }
  if (username) {
    [dictionary setValue:username forKey:@"username"];
  }
  if (sourceFilePath) {
    [dictionary setValue:sourceFilePath forKey:@"sourceFilepath"];
  }
  if (destFilePath) {
    [dictionary setValue:destFilePath forKey:@"destFilepath"];
  }
  [dictionary setValue:time forKey:@"time"];
  if (eventType) {
    [dictionary setValue:eventType forKey:@"event"];
  }
  if (childPID) {
    [dictionary setValue:childPID forKey:@"childPID"];
  }
  if (execImage) {
    [dictionary setValue:execImage forKey:@"execImage"];
  }
  if (exitStatus) {
    [dictionary setValue:exitStatus forKey:@"exitStatus"];
  }
  if (nsec) {
    [dictionary setValue:nsec forKey:@"nsec"];
  }
  return dictionary;
}

- (NSNumber *)getTimestamp:(es_message_t *) message {
  return [NSNumber numberWithLong: message->time.tv_nsec];
}

- (NSString *)getEventType:(es_message_t *) message {
  switch (message->event_type) {
    case ES_EVENT_TYPE_NOTIFY_WRITE:
      return @"WRITE";
    case ES_EVENT_TYPE_NOTIFY_EXEC:
      return @"EXEC";
    case ES_EVENT_TYPE_NOTIFY_FORK:
      return @"FORK";
    case ES_EVENT_TYPE_NOTIFY_EXIT:
      return @"EXIT";
    case ES_EVENT_TYPE_NOTIFY_CREATE:
      return @"CREATE";
    case ES_EVENT_TYPE_NOTIFY_OPEN:
      return @"OPEN";
    case ES_EVENT_TYPE_NOTIFY_RENAME: {
      NSString *filepath = [self extractDestinationFilepath:message];
      NSString *filename = [[filepath componentsSeparatedByString:@"/"] lastObject];
      if (filename) {
        NSString *trashPath = [@"/.Trash/" stringByAppendingString:filename];
        if ([filepath hasSuffix:trashPath]) {
          return @"DELETE";
        } else if ([self extractSourceFilePath:message]) {
          return @"MOVE";
        }
      }
      return @"RENAME";
    }
    default:
      return nil;
  }
}

- (NSString*) getPID:(es_message_t *) message {
  pid_t pid = audit_token_to_pid(message->process->audit_token);
  return [[NSNumber numberWithUnsignedInt: pid] description];
}

- (NSString *) getChildPID:(es_message_t *) message {
  switch (message->event_type) {
    case ES_EVENT_TYPE_NOTIFY_FORK: {
      pid_t pid = audit_token_to_pid(message->event.fork.child->audit_token);
      return [[NSNumber numberWithUnsignedInt: pid] description];
    }
    default:
      return nil;
  }
}

- (NSString *) getUsername:(es_message_t *) message {
  uid_t uid = audit_token_to_euid(message->process->audit_token);
  struct passwd* pwd = getpwuid(uid);
  if (pwd == NULL) {
    return [[NSNumber numberWithUnsignedInt: uid] description];
  } else {
    return [NSString stringWithCString:pwd->pw_name encoding:NSASCIIStringEncoding];
  }
}

- (NSString *) getExitStatus:(es_message_t *) message {
  switch (message->event_type) {
    case ES_EVENT_TYPE_NOTIFY_EXIT:
      return [[NSNumber numberWithInt:message->event.exit.stat] description];
    default:
      return nil;
  }
}

- (NSString *) extractSourceFilePath:(es_message_t *) message {
  switch (message->event_type) {
    case ES_EVENT_TYPE_NOTIFY_EXEC:
      return [self convertStringToken:&message->process->executable->path];
    case ES_EVENT_TYPE_NOTIFY_FORK:
      return [self convertStringToken:&message->process->executable->path];
    case ES_EVENT_TYPE_NOTIFY_EXIT:
      return [self convertStringToken:&message->process->executable->path];
    case ES_EVENT_TYPE_NOTIFY_RENAME: {
      NSString* filepath = [self convertStringToken:&message->event.rename.source->path];
      return filepath;
    }
    case ES_EVENT_TYPE_NOTIFY_WRITE:
      return [self convertStringToken:&message->event.write.target->path];
    default:
      return nil;
  }
}

- (NSString *) getExecImage:(es_message_t *) message {
  switch (message->event_type) {
    case ES_EVENT_TYPE_NOTIFY_EXEC:
      return [self convertStringToken:&message->event.exec.target->executable->path];
    default:
      return nil;
  }
}

- (NSString*) extractDestinationFilepath:(es_message_t *) message {
  switch (message->event_type) {
    case ES_EVENT_TYPE_NOTIFY_CREATE: {
      NSString* path = [self convertStringToken:&message->event.create.destination.new_path.dir->path];
      NSString* filename = [self convertStringToken:&message->event.create.destination.new_path.filename];
      NSString* filepath = [path stringByAppendingPathComponent: filename];
      return filepath;
    }
    case ES_EVENT_TYPE_NOTIFY_OPEN:
      return [self convertStringToken:&message->event.open.file->path];
    case ES_EVENT_TYPE_NOTIFY_RENAME: {
      NSString* path = [self convertStringToken:&message->event.rename.destination.new_path.dir->path];
      NSString* filename = [self convertStringToken:&message->event.rename.destination.new_path.filename];
      NSString* filepath = [path stringByAppendingPathComponent: filename];
      return filepath;
    }
    default:
      return nil;
  }
}

- (NSString*) convertStringToken: (es_string_token_t*) stringToken {
  NSString* string = nil;
  
  if ((NULL == stringToken) ||
      (NULL == stringToken->data) ||
      (stringToken->length <= 0)) {
    return string;
  }
  
  string = [
    NSString stringWithUTF8String:[
      [NSData dataWithBytes:stringToken->data
                     length:stringToken->length
      ] bytes
    ]
  ];
  
  return string;
}

@end
