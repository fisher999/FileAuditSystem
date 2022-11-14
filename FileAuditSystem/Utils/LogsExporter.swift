//
//  LogsExporter.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 13.11.2022.
//

import Foundation

class LogsExporter {
  private var connection: NSXPCConnection?
  private var service: ILogsProvider?
  private let logger: Logger
  
  init(logger: Logger) {
    self.logger = logger
  }
  
  func export(url: URL) throws {
    createConnection()
    service?.provideLogs { [weak self] data in
      guard let logs = data else {
        self?.logger.log(message: "No logs", level: .info)
        return
      }
      
      do {
        try logs.write(to: url)
      } catch {
        self?.logger.log(message: "Failed to write logs to \(url.filePath)", level: .error)
      }
    }
  }
  
  func setDirectories(urls: [String]) {
    createConnection()
    service?.setDirectories(urls)
  }
  
  private func createConnection() {
    connection = NSXPCConnection(machServiceName: logsProviderServiceName)
    connection?.remoteObjectInterface = NSXPCInterface(with: ILogsProvider.self)
    
    connection?.invalidationHandler = { [weak self] in
      self?.logger.log(message: "Connection did invalidate", level: .info)
    }
    connection?.interruptionHandler = { [weak self] in
      self?.logger.log(message: "Connection did interrupt", level: .info)
    }
    
    connection?.resume()
    service = self.connection?.remoteObjectProxyWithErrorHandler { error in
      self.logger.log(message: "XPC connection error: \(error as NSError)", level: .error)
    } as? ILogsProvider
    
    if service == nil {
      self.logger.log(message: "Failed to create service connection", level: .error)
    }
  }
}
