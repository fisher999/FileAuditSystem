//
//  FileOutput.swift
//  Logger
//
//  Created by Виктор Семенов on 12.11.2022.
//

import Foundation
import OSLog

public protocol FileOutputDelegate: AnyObject {
  func fileOutput(_ fileOutput: FileOutput, didFailWriteToFile fileURL: URL, error: Error)
  func fileOutput(_ fileOutput: FileOutput, didWriteMessage message: String)
}

public extension FileOutputDelegate {
  func fileOutput(_ fileOutput: FileOutput, didWriteMessage message: String) {}
}

public class FileOutput: ILoggerOutput {
  public weak var delegate: FileOutputDelegate?
  
  private let fileURL: URL
  private let fileManager = FileManager.default
  
  public init(path: String, file: String) {
    let url = FileManager.default.homeDirectoryForCurrentUser
    if #available(macOS 13.0, *) {
      self.fileURL = url.appending(path: path + "/\(file)")
    } else {
      self.fileURL = url.appendingPathComponent(path + "/\(file)")
    }
  }
  
  public func log(message: String) {
    guard let data = (message + "\n").data(using: .utf8) else { return }
    createFileIfNeeded()
    do {
      let fileHandle = try FileHandle(forWritingTo: fileURL)
      fileHandle.seekToEndOfFile()
      fileHandle.write(data)
      fileHandle.closeFile()
      os_log(.default, "Success logged at file \(self.fileURL.absoluteString)")
    } catch {
      os_log(.error, "\(error.localizedDescription)")
      delegate?.fileOutput(self, didFailWriteToFile: fileURL, error: error)
    }
  }
  
  private func createFileIfNeeded() {
    let filePath: String
    if #available(macOS 13.0, *) {
      filePath = fileURL.path()
    } else {
      filePath = fileURL.path
    }
    guard !fileManager.fileExists(atPath: filePath) else {
      return
    }
    fileManager.createFile(atPath: filePath, contents: nil)
  }
}
