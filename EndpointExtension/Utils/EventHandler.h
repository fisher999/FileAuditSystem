//
//  EventHandler.h
//  EndpointExtension
//
//  Created by Виктор Семенов on 12.11.2022.
//

#import <Foundation/Foundation.h>
#include <EndpointSecurity/EndpointSecurity.h>
#include <bsm/libbsm.h>
#include <os/log.h>

@interface EventHandler : NSObject

- (NSDictionary *)handleMessage: (es_message_t *)message;

@end
