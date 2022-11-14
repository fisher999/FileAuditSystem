//
//  URL+FilePath.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 13.11.2022.
//

import Foundation

extension URL {
  var filePath: String {
    if #available(macOS 13.0, *) {
      return path(percentEncoded: false)
    } else {
      return path
    }
  }
}
