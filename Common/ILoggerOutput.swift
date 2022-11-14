//
//  ILoggerOutput.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation

protocol ILoggerOutput: AnyObject {
  func log(message: String)
}
