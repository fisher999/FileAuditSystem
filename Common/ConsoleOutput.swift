//
//  ConsoleOutput.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation

class ConsoleOutput: ILoggerOutput {
  init() {}
  
  func log(message: String) {
    print(message)
  }
}
