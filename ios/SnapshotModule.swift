// import ExpoModulesCore
// import UIKit

// class SnapshotModule: Module {
//     private var cachedImage: UIImage?

//     public func definition() -> ModuleDefinition {
//       Name("SnapshotModule")

//       AsyncFunction("captureScreen") { (options: [String: Any], promise: Promise) in
//            // Get the active window scene
//            guard let windowScene = UIApplication.shared.connectedScenes
//                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//                let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
//                promise.reject("E_NO_WINDOW", "No active window found")
//                return
//            }

//            // Parse options
//            let format = (options["format"] as? String)?.lowercased() ?? "png"
//            let quality: CGFloat
//            if let qualityValue = options["quality"] as? Double {
//                quality = max(0.0, min(1.0, CGFloat(qualityValue) / 100.0))
//            } else {
//                quality = format == "png" ? 1.0 : 0.9
//            }

//            // Capture screen
//            UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
//            defer { UIGraphicsEndImageContext() }

//            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)

//            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
//                promise.reject("E_CAPTURE_FAILED", "Failed to capture screen")
//                return
//            }

//            // Convert to requested format
//            var imageData: Data?
//            switch format {
//            case "jpg", "jpeg":
//                imageData = image.jpegData(compressionQuality: quality)
//            default: // png
//                imageData = image.pngData()
//            }

//            guard let data = imageData else {
//                promise.reject("E_CONVERSION_FAILED", "Failed to convert image to \(format.uppercased())")
//                return
//            }

//            promise.resolve(data.base64EncodedString())
//        }
//     }
// }


import ExpoModulesCore

public class SnapshotModule: Module {
  public func definition() -> ModuleDefinition {
    Name("SnapshotModule")
    // can add functions here later

    // AsyncFunction("captureScreen") {(options: [String: Any], promise: Promise) in
    //   // Get the active window scene
    //        guard let windowScene = UIApplication.shared.connectedScenes
    //            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
    //            let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
    //            promise.reject("E_NO_WINDOW", "No active window found")
    //            return
    //        }

    //        // Parse options
    //        let format = (options["format"] as? String)?.lowercased() ?? "png"
    //        let quality: CGFloat
    //        if let qualityValue = options["quality"] as? Double {
    //            quality = max(0.0, min(1.0, CGFloat(qualityValue) / 100.0))
    //        } else {
    //            quality = format == "png" ? 1.0 : 0.9
    //        }

    //        // Capture screen
    //        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
    //        defer { UIGraphicsEndImageContext() }

    //        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)

    //        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
    //            promise.reject("E_CAPTURE_FAILED", "Failed to capture screen")
    //            return
    //        }

    //         // Convert to requested format
    //        var imageData: Data?
    //        switch format {
    //        case "jpg", "jpeg":
    //            imageData = image.jpegData(compressionQuality: quality)
    //        default: // png
    //            imageData = image.pngData()
    //        }

    //        guard let data = imageData else {
    //            promise.reject("E_CONVERSION_FAILED", "Failed to convert image to \(format.uppercased())")
    //            return
    //        }

    //        promise.resolve(data.base64EncodedString())
    //        return

    // }

    // AsyncFunction("captureScreen") { (options: [String: Any], promise: Promise) in
    // DispatchQueue.main.async {
    //     do {
    //         // Parse options on main thread
    //         let format = (options["format"] as? String)?.lowercased() ?? "png"
    //         let quality: CGFloat
    //         if let qualityValue = options["quality"] as? Double {
    //             quality = max(0.0, min(1.0, CGFloat(qualityValue) / 100.0))
    //         } else {
    //             quality = format == "png" ? 1.0 : 0.9
    //         }
            
    //         // Get window on main thread
    //         guard let windowScene = UIApplication.shared.connectedScenes
    //             .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
    //             let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
    //             promise.reject("E_NO_WINDOW", "No active window found")
    //             return
    //         }
            
    //         // Capture screen
    //         UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, UIScreen.main.scale)
    //         defer { UIGraphicsEndImageContext() }
            
    //         window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            
    //         guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
    //             promise.reject("E_CAPTURE_FAILED", "Failed to capture screen")
    //             return
    //         }
            
    //         // Convert to requested format (can be done off main thread)
    //         DispatchQueue.global(qos: .userInitiated).async {
    //             var imageData: Data?
    //             switch format {
    //             case "jpg", "jpeg":
    //                 imageData = image.jpegData(compressionQuality: quality)
    //             default: // png
    //                 imageData = image.pngData()
    //             }
                
    //             DispatchQueue.main.async {
    //                 guard let data = imageData else {
    //                     promise.reject("E_CONVERSION_FAILED", "Failed to convert image to \(format.uppercased())")
    //                     return
    //                 }
    //                 promise.resolve(data.base64EncodedString())
    //             }
    //         }
    //     } catch {
    //         promise.reject("E_UNKNOWN", "Unexpected error: \(error.localizedDescription)")
    //     }
    // }
    

    AsyncFunction("captureScreen") { (options: [String: Any], promise: Promise) in
        // Parse options first (thread-safe operation)
        let format = (options["format"] as? String)?.lowercased() ?? "png"
        let quality: CGFloat = {
            if let qualityValue = options["quality"] as? Double {
                return max(0.0, min(1.0, CGFloat(qualityValue) / 100.0))
            }
            return format == "png" ? 1.0 : 0.9
        }()

        DispatchQueue.main.async {
            // Modern window scene access
            guard let activeScene = UIApplication.shared.foregroundActiveScene,
                  let window = activeScene.windows.first(where: \.isKeyWindow) else {
                promise.reject("E_NO_WINDOW", "No active window found")
                return
            }

            // Modern image renderer (iOS 10+)
            let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: {
                let format = UIGraphicsImageRendererFormat()
                format.scale = window.screen.scale 
                format.opaque = false
                return format
            }())

            let image = renderer.image { context in
                // Improved rendering with options
                window.drawHierarchy(
                    in: window.bounds,
                    afterScreenUpdates: false // Better performance than true
                )
            }

            // Offload image processing
            DispatchQueue.global(qos: .userInitiated).async {
                let result: Result<String, Error>
                
                do {
                    let data: Data?
                    switch format {
                    case "jpg", "jpeg":
                        data = image.jpegData(compressionQuality: quality)
                    default:
                        data = image.pngData()
                    }
                    
                    guard let imageData = data else {
                        throw NSError(domain: "ImageConversion", code: 0, userInfo: [
                            NSLocalizedDescriptionKey: "Failed to convert image to \(format.uppercased())"
                        ])
                    }
                    
                    result = .success(imageData.base64EncodedString())
                } catch {
                    result = .failure(error)
                }
                
                // Return to main thread to resolve promise
                DispatchQueue.main.async {
                    switch result {
                    case .success(let base64String):
                        promise.resolve(base64String)
                    case .failure(let error):
                        promise.reject("E_CAPTURE_FAILED", error.localizedDescription)
                    }
                }
            }
        }
    }


    


  }

}

// Helper extension for scene management
extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } 
            as? UIWindowScene
    }
}


