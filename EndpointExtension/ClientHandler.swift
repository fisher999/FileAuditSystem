//
//  ClientHandler.swift
//  EndpointExtension
//
//  Created by Виктор Семенов on 13.11.2022.
//

import Foundation
import EndpointSecurity

class ClientHandler: NSObject, ILogsProvider {
  private let logger: Logger
  private let eventHandler = EventHandler()
  private var logsOutput: FileOutput?
  private var paths: [String] = []
  private var shouldIgnoreDSStore: Bool
  
  init(logger: Logger, ignoringDsStore: Bool = true) {
    self.logger = logger
    shouldIgnoreDSStore = ignoringDsStore
  }
  
  func handle(_ message: UnsafePointer<es_message_t>) {
    guard let event = eventHandler.handle(UnsafeMutablePointer(mutating: message)) else {
      return
    }
    guard isValidFilepath(event) else {
      return
    }
    do {
      let data = try JSONSerialization.data(withJSONObject: event, options: .prettyPrinted)
      guard let message = String(data: data, encoding: .utf8) else {
        return
      }
      logger.log(message: message, level: .info)
    } catch {
      logger.log(message: "Error logging event: \(error as NSError)", level: .error)
    }
  }
  
  func setDirectories(_ urls: [String]) {
    self.paths = urls
    if let oldLogsOutput = self.logsOutput {
      logger.remove(oldLogsOutput)
    }
    
    let logsOutput = FileOutput(path: "", file: UUID().uuidString)
    self.logsOutput = logsOutput
    logger.append(logsOutput)
    logger.log(message: "Did set directories \(urls)", level: .info)
  }
  
  func provideLogs(replyBlock: @escaping ReplyBlock) {
    guard let logsOutput = self.logsOutput else {
      logger.log(message: "No logs output", level: .error)
      replyBlock(nil)
      return
    }
    do {
      let data = try logsOutput.getData()
      replyBlock(data)
      try logsOutput.removeData()
    } catch {
      logger.log(message: "Error getting logs, Error: \(error as NSError)", level: .error)
      replyBlock(nil)
    }
  }
  
  private func isValidFilepath(_ event: [AnyHashable : Any]) -> Bool {
    guard let filePath = event["destFilepath"] as? String else {
      return false
    }
    if shouldIgnoreDSStore && filePath.components(separatedBy: "/").last == ".DS_Store" {
      return false
    }
    return paths.contains {
      if filePath.hasPrefix($0) {
        return true
      } else if let sourceFilePath = event["sourceFilepath"] as? String {
        return sourceFilePath.hasPrefix($0)
      } else {
        return false
      }
    }
  }
}
