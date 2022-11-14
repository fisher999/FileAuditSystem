//
//  ViewController.swift
//  FileAuditSystem
//
//  Created by Виктор Семенов on 09.11.2022.
//

import Cocoa
import SystemExtensions

class ViewController: NSViewController {
  // MARK: - Views
  @IBOutlet private weak var directoriesTextView: NSTextView!
  @IBOutlet private weak var installButton: NSButton!
  @IBOutlet private weak var textView: NSTextView!
  let openPanel = NSOpenPanel()
  let savePanel = NSSavePanel()
  
  // MARK: - Properties
  private var currentRequest: OSSystemExtensionRequest?
  private lazy var logger = Logger(
    outputs: [
      textView,
      ConsoleOutput(),
      FileOutput(path: "", file: "logs.txt"),
      OSLogger.filesMonitor
    ]
  )
  private lazy var logsExporter = LogsExporter(logger: logger)
  private var urls: [URL] = [] {
    didSet {
      directoriesTextView.setString("Directories: " + "\(urls.map { $0.filePath })")
    }
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  // MARK: - IBActions  
  @IBAction func didTapInstallExtension(_ button: NSButton) {
    installExtension()
  }
  
  @IBAction func didTapExportLogs(_ button: NSButton) {
    guard !urls.isEmpty else {
      let alert = NSAlert()
      alert.messageText = "Please, select directories"
      alert.addButton(withTitle: "Ok")
      alert.runModal()
      return
    }
    savePanel.beginSheetModal(for: view.window!) { [weak self] result in
      guard let self = self else { return }
      guard result == .OK, let url = self.savePanel.url else { return }
      do {
        try self.logsExporter.export(url: url)
      } catch {
        self.logger.log(
          message: "Cant export log to \(url.absoluteString). Error: \(error.localizedDescription)",
          level: .error
        )
      }
    }
  }
  
  @IBAction func didTapSelectDirectories(_ button: NSButton) {
    openPanel.beginSheetModal(for: view.window!) { [weak self] result in
      guard let self = self else { return }
      let urls = self.openPanel.urls
      guard result == .OK, !urls.isEmpty else { return }
      self.urls = urls
      let dirs = urls.map { $0.filePath }
      self.logsExporter.setDirectories(urls: dirs)
      self.logger.log(
        message: "Did start monitoring for directories: \(dirs)",
        level: .info
      )
    }
  }

  // MARK: - Private
  private func setupView() {
    // TextView
    textView.isEditable = false
    
    // Directories text view
    directoriesTextView.isEditable = false
    directoriesTextView.setString("Directories: ")
    
    // Save panel
    savePanel.title = "Export Logs"
    savePanel.prompt = "Save"
    savePanel.canCreateDirectories = true
    
    // Open panel
    openPanel.title = "Choose directories"
    openPanel.prompt = "Select"
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = true
  }
  
  private func installExtension() {
    guard currentRequest == nil else {
      logger.log(message: "Already requested install", level: .warning)
      return
    }
    
    logger.log(message: "Beginning to install the extension", level: .info)
    
    let request = OSSystemExtensionRequest.activationRequest(
      forExtensionWithIdentifier: "com.viktor.FileAuditSystem.EndpointExtension",
      queue: .main
    )
    request.delegate = self
    
    OSSystemExtensionManager.shared.submitRequest(request)
    currentRequest = request
    logger.log(message: "Begin installing the extension 🔄", level: .info)
  }
}

extension ViewController: OSSystemExtensionRequestDelegate {
  func request(
    _ request: OSSystemExtensionRequest,
    actionForReplacingExtension existing: OSSystemExtensionProperties,
    withExtension ext: OSSystemExtensionProperties
  ) -> OSSystemExtensionRequest.ReplacementAction {
    logger.log(
      message: "Got the upgrade request (\(existing.bundleVersion) -> \(ext.bundleVersion)); answering replace.",
      level: .info
    )
    return .replace
  }
  
  func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
    if (request != currentRequest) {
      logger.log(
        message: "UNEXPECTED NON-CURRENT Request to activate \(request.identifier) succeeded.",
        level: .info
      )
      return
    }
    logger.log(message: "Request to activate \(request.identifier) awaiting approval.", level: .info)
    logger.log(message: "Awaiting Approval ⏱", level: .info)
  }
  
  func request(
    _ request: OSSystemExtensionRequest,
    didFinishWithResult result: OSSystemExtensionRequest.Result
  ) {
    if (request != currentRequest) {
      logger.log(
        message: "UNEXPECTED NON-CURRENT Request to activate \(request.identifier) succeeded.",
        level: .info
      )
      return
    }
    logger.log(
      message: "Request to activate \(request.identifier) succeeded (\(result))",
      level: .info
    )
    logger.log(message: "Successfully installed the extension", level: .info)
    self.currentRequest = nil;
  }
  
  func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
    if (request != currentRequest) {
      logger.log(
        message: "UNEXPECTED NON-CURRENT Request to activate \(request.identifier) failed with error \(error.localizedDescription)",
        level: .error
      )
      return
    }
    logger.log(
      message: "UNEXPECTED NON-CURRENT Request to activate \(request.identifier) failed with error \(error.localizedDescription). Failed to install extension",
      level: .error
    )
    currentRequest = nil;
  }
}
