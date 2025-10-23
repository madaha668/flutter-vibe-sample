import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var serviceBrowser: NetServiceBrowser?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Trigger Local Network permission prompt on iOS 14+
    triggerLocalNetworkPermission()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func triggerLocalNetworkPermission() {
    // Create a NetServiceBrowser to trigger the Local Network permission dialog
    // This is required on iOS 14+ to access local network devices
    serviceBrowser = NetServiceBrowser()
    serviceBrowser?.searchForServices(ofType: "_http._tcp.", inDomain: "local.")

    // Stop the search after a brief delay - we only need to trigger the permission
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.serviceBrowser?.stop()
      self?.serviceBrowser = nil
    }
  }
}
