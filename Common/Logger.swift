//
//  Logger.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation

enum LogLevel: String {
  case info = "🟢INFO"
  case warning = "⚠️WARNING"
  case error = "❌ERROR"
}

class Logger {
  // MARK: - Properties
  private var outputs: [ILoggerOutput]
  private let dateFormatter = DateFormatter()
  
  // MARK: - Init
  init(outputs: [ILoggerOutput]) {
    self.outputs = outputs
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  }
  
  func log(message: String, level: LogLevel) {
    outputs.forEach { $0.log(message: makeMessage(message, withLevel: level)) }
  }
  
  func append(_ output: ILoggerOutput) {
    outputs.append(output)
  }
  
  func remove(_ output: ILoggerOutput) {
    outputs.removeAll { $0 === output }
  }
  
  private func makeMessage(_ message: String, withLevel level: LogLevel) -> String {
    let date = Date()
    let dateString = dateFormatter.string(from: date)
    let logMessage = "[\(level.rawValue) \(dateString)] \(message)"
    return logMessage
  }
}
