//
//  Logger.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation

public enum LogLevel: String {
  case info = "🟢INFO"
  case warning = "⚠️WARNING"
  case error = "❌ERROR"
}

public struct Logger {
  // MARK: - Properties
  private let outputs: [ILoggerOutput]
  private let dateFormatter = DateFormatter()
  
  // MARK: - Init
  public init(outputs: [ILoggerOutput]) {
    self.outputs = outputs
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  }
  
  public func log(message: String, level: LogLevel) {
    outputs.forEach { $0.log(message: makeMessage(message, withLevel: level)) }
  }
  
  private func makeMessage(_ message: String, withLevel level: LogLevel) -> String {
    let date = Date()
    let dateString = dateFormatter.string(from: date)
    let logMessage = "[\(level.rawValue) \(dateString)] \(message)"
    return logMessage
  }
}
