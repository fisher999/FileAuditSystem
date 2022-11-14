//
//  ConsoleOutput.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation

public class ConsoleOutput: ILoggerOutput {
  public init() {}
  
  public func log(message: String) {
    print(message)
  }
}
