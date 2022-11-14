//
//  ILogsProvider.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 13.11.2022.
//

import Foundation

let logsProviderServiceName = "fileAuditSystem.EndpointExtension"

typealias ReplyBlock = (Data?) -> ()

@objc protocol ILogsProvider {
  func setDirectories(_ urls: [String])
  func provideLogs(replyBlock: @escaping ReplyBlock)
}
