//
//  main.swift
//  EndpointExtension
//
//  Created by Виктор Семенов on 09.11.2022.
//

import Foundation
import EndpointSecurity

var client: OpaquePointer?
let logger = Logger(outputs: [FileOutput(path: "", file: "debug.txt"), OSLogger.filesMonitor])
let clientHandler = ClientHandler(logger: logger)

// Create the client
let res = es_new_client(&client) { (client, message) in
  clientHandler.handle(message)
}

if res != ES_NEW_CLIENT_RESULT_SUCCESS {
    exit(EXIT_FAILURE)
}

let events: [es_event_type_t] = [
  ES_EVENT_TYPE_NOTIFY_CREATE,
  ES_EVENT_TYPE_NOTIFY_OPEN,
  ES_EVENT_TYPE_NOTIFY_WRITE,
  ES_EVENT_TYPE_NOTIFY_RENAME,
  ES_EVENT_TYPE_NOTIFY_EXEC,
  ES_EVENT_TYPE_NOTIFY_FORK,
  ES_EVENT_TYPE_NOTIFY_EXIT
]

if es_subscribe(client!, events, UInt32(events.count)) != ES_RETURN_SUCCESS {
  logger.log(message: "Can't subscribe on events", level: .error)
}

logger.log(message: "Extension started", level: .info)

let listener = NSXPCListener(machServiceName: logsProviderServiceName)
let listenerDelegate = ListenerDelegate(logger: logger, clientHandler: clientHandler)

listener.delegate = listenerDelegate
listener.resume()

dispatchMain()
