import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        // ✅ Must match Android channel name exactly
        let channel = FlutterMethodChannel(
            name: "com.code/document_processor",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { call, result in
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }

            switch call.method {
            case "processDocument":
                guard let imageData = (args["imageBytes"] as? FlutterStandardTypedData)?.data else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                    return
                }
                if let processed = DocumentCV.processDocument(imageData) {
                    result(FlutterStandardTypedData(bytes: processed))
                } else {
                    result(FlutterError(code: "PROCESSING_ERROR", message: "Failed to process document", details: nil))
                }

            case "detectCorners":
                guard let imageData = (args["imageBytes"] as? FlutterStandardTypedData)?.data else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes", details: nil))
                    return
                }
                // ✅ Return nil (not error) when no corners found — Dart side handles null
                result(DocumentCV.detectCorners(imageData))

            case "perspectiveTransform":
                guard let imageData = (args["imageBytes"] as? FlutterStandardTypedData)?.data,
                      let corners = args["corners"] as? [Double] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing imageBytes or corners", details: nil))
                    return
                }
                let nativeCorners = corners.map { NSNumber(value: $0) }
                if let warped = DocumentCV.perspectiveTransform(imageData, corners: nativeCorners) {
                    result(FlutterStandardTypedData(bytes: warped))
                } else {
                    result(FlutterError(code: "TRANSFORM_ERROR", message: "Failed to transform", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
