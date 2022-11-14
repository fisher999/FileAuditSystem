//
//  OSLogger.swift
//  Logger
//
//  Created by Виктор Семенов on 12.11.2022.
//

import Foundation
import OSLog

public class OSLogger: ILoggerOutput {
  public static var filesMonitor: OSLogger {
    return OSLogger(category: "filesMonitor")
  }
  
  private let log: OSLog
  
  public init(category: String) {
    self.log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: category)
  }
  
  public func log(message: String) {
    os_log(.default, log: log, "%{public}s", message)
  }
}
