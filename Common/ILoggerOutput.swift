//
//  ILoggerOutput.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation

public protocol ILoggerOutput {
  func log(message: String)
}
