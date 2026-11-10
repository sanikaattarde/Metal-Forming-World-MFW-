import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let messenger = engineBridge.pluginRegistry.registrar(forPlugin: "MfwStorage")?.messenger() {
      registerStorageChannel(messenger)
    }
  }

  // Issue file storage for MOD-06 (CODING_STANDARDS.md section 8.2): the
  // Application Support directory, excluded from device backups because the
  // files can be downloaded again, and the free space before a download
  // (RS FR-STATE-004).
  private func registerStorageChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "mfw/storage", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "issueDirectory":
        do {
          let support = try FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true)
          var dir = support.appendingPathComponent("issues", isDirectory: true)
          try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
          var values = URLResourceValues()
          values.isExcludedFromBackup = true
          try dir.setResourceValues(values)
          result(dir.path)
        } catch {
          result(FlutterError(code: "storage", message: nil, details: nil))
        }
      case "freeBytes":
        let path = (call.arguments as? String) ?? NSHomeDirectory()
        let url = URL(fileURLWithPath: path)
        if let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
          let bytes = values.volumeAvailableCapacityForImportantUsage
        {
          result(NSNumber(value: bytes))
        } else {
          result(FlutterError(code: "storage", message: nil, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
