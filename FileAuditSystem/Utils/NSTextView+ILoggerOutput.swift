//
//  NSTextView+ILoggerOutput.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 10.11.2022.
//

import Foundation
import AppKit

extension NSTextView: ILoggerOutput {
  func log(message: String) {
    DispatchQueue.main.async {
      self.textStorage?.append(NSAttributedString(string: "\(message)\n"))
    }
  }
}
