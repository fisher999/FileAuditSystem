//
//  NSTextView+String.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 13.11.2022.
//

import Cocoa

extension NSTextView {
  func setString(_ string: String) {
    textStorage?.setAttributedString(NSAttributedString(string: string))
  }
}
