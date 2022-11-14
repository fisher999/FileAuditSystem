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
  
  func createDirectoryIfNeeded() throws {
    let fileManager = FileManager.default
    let directory = deletingLastPathComponent().filePath
    var isDir: ObjCBool = true
    if !fileManager.fileExists(
      atPath: directory,
      isDirectory: &isDir
    ) {
      try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true)
    }
  }
}
