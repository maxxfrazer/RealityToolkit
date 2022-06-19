//
//  RealityToolkit.swift
//  
//
//  Created by Max Cobb on 14/05/2022.
//

import Foundation
import OSLog

/// RealityToolkit contains some properties for RealityToolkit Modlule.
@objc public class RealityToolkit: NSObject {
    internal static func RUIPrint(_ message: String) {
        #if DEBUG
        print("RealityToolkit: \(message)")
        #endif
    }

    /// Errors for when an external failed to load
    public enum LoadRemoteError: Error {
        /// Cannot override local file of the same name
        case cannotDelete
        /// File could not be downloaded
        case downloadError
        /// A local URL was given instead of a remote one, and the local file does not exist.
        case localURLProvided
    }

    /// Download a remote file from a URL to a destination directory or an exact filepath.
    /// - Parameters:
    ///   - url: URL of the source. Pass a remote URL for this.
    ///   - destination: Destination path or exact file URL.
    ///   - useCache: Use the local file if it already exists. Default `true`
    /// - Returns: Returns the URL the file is downloaded to.
    public static func downloadRemoteFile(
        contentsOf url: URL, saveTo destination: URL? = nil, useCache: Bool = true
    ) async throws -> URL {
            if !url.absoluteString.hasPrefix("http") {
                RealityToolkit.RUIPrint("URL is already local. To move the file, call `FileManager.default.moveItem`")
                if FileManager.default.fileExists(atPath: url.path) { return url }
                RealityToolkit.RUIPrint("File at local URL does not exist.")
                throw LoadRemoteError.localURLProvided
            }
            let filename = url.lastPathComponent
            var endLocation = destination ?? FileManager.default.temporaryDirectory
            if endLocation.hasDirectoryPath {
                endLocation.appendPathComponent(filename)
            }
            if FileManager.default.fileExists(atPath: endLocation.path) {
                if useCache {
                    return endLocation
                }
                do {
                    try FileManager.default.removeItem(atPath: endLocation.path)
                } catch let err {
                    RealityToolkit.RUIPrint("Could not remove item: \(err)")
                    throw LoadRemoteError.cannotDelete
                }
            }
            if #available(iOS 15.0, macOS 12.0, *) {
                let (moveFrom, _) = try await URLSession.shared.download(from: url)
                try FileManager.default.moveItem(
                    atPath: moveFrom.path, toPath: endLocation.path
                )
            } else {
              let data = try Data(contentsOf: url)
              try data.write(to: endLocation)
            }
            return endLocation
        }
}
