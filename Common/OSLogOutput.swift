//
//  OSLogger.swift
//  Logger
//
//  Created by Виктор Семенов on 12.11.2022.
//

import Foundation
import OSLog

class OSLogger: ILoggerOutput {
  static var filesMonitor: OSLogger {
    return OSLogger(category: "filesMonitor")
  }
  
  private let log: OSLog
  
  init(category: String) {
    self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category)
  }
  
  func log(message: String) {
    os_log(.default, log: log, "%{public}s", message)
  }
}
