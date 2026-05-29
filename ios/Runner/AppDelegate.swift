import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let widgetSettingsChannelName = "ios_club_app/widget_settings"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 13.0, *) {
      WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "widgetUpdate",
        frequency: NSNumber(value: 30 * 60)
      )
      WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "courseReminder",
        frequency: NSNumber(value: 2 * 60 * 60)
      )
    }

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: widgetSettingsChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "openWidgetSetup" else {
          result(FlutterMethodNotImplemented)
          return
        }

        self?.openWidgetSetup(result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func openWidgetSetup(result: @escaping FlutterResult) {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      result("unavailable")
      return
    }

    UIApplication.shared.open(url, options: [:]) { success in
      result(success ? "appSettingsOpened" : "unavailable")
    }
  }
}
