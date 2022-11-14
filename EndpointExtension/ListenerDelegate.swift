//
//  ListenerDelegate.swift
//  EndpointExtension
//
//  Created by Виктор Семенов on 13.11.2022.
//

import Foundation

class ListenerDelegate: NSObject, NSXPCListenerDelegate {
  private let logger: Logger
  weak var clientHandler: ClientHandler?
  
  init(logger: Logger, clientHandler: ClientHandler) {
    self.logger = logger
    self.clientHandler = clientHandler
    super.init()
    defer {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        self.logger.log(message: "Listener delegate working. \(self)", level: .info)
      }
    }
  }
  
  func listener(
    _ listener: NSXPCListener,
    shouldAcceptNewConnection newConnection: NSXPCConnection
  ) -> Bool {
    logger.log(message: "Did call accept new connection", level: .info)
    guard let clientHandler = clientHandler else {
      logger.log(message: "No client handler", level: .info)
      return false
    }
    newConnection.exportedInterface = NSXPCInterface(with: ILogsProvider.self)
    newConnection.exportedObject = clientHandler
    
    newConnection.invalidationHandler = { [weak self] in
      self?.logger.log(message: "Connection did invalidate", level: .info)
    }
    newConnection.interruptionHandler = { [weak self] in
      self?.logger.log(message: "Connection did interrupt", level: .info)
    }
    
    newConnection.resume()
    
    return true
  }
}
