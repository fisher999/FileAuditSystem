//
//  FileOutput.swift
//  Logger
//
//  Created by Виктор Семенов on 12.11.2022.
//

import Foundation
import OSLog

class FileOutput: ILoggerOutput {
  let fileURL: URL
  private let fileManager = FileManager.default
  
  init(path: String, file: String) {
    let url = FileManager.default.homeDirectoryForCurrentUser
    if #available(macOS 13.0, *) {
      self.fileURL = url.appending(path: path + "/\(file)")
    } else {
      self.fileURL = url.appendingPathComponent(path + "/\(file)")
    }
  }
  
  func log(message: String) {
    guard let data = (message + "\n").data(using: .utf8) else { return }
    do {
      try createFileIfNeeded()
      let fileHandle = try FileHandle(forWritingTo: fileURL)
      fileHandle.seekToEndOfFile()
      fileHandle.write(data)
      fileHandle.closeFile()
      os_log(.debug, "Successfuly logged at file %{public}s", fileURL.filePath)
    } catch {
      os_log(.error, "\(error.localizedDescription)")
    }
  }
  
  func getData() throws -> Data {
    return try Data(contentsOf: fileURL)
  }
  
  func removeData() throws {
    if fileManager.fileExists(atPath: fileURL.filePath) {
      try fileManager.removeItem(at: fileURL)
    }
  }
  
  private func createFileIfNeeded() throws {
    let filePath = fileURL.filePath
    guard !fileManager.fileExists(atPath: filePath) else {
      return
    }
    try fileURL.createDirectoryIfNeeded()
    fileManager.createFile(atPath: filePath, contents: nil)
  }
}
