//
//  RealityToolkit+LoadingAssets.swift
//  Methods for converting downloading remote image or USDZ files
//  to be converted a TextureResource or Entity.
//
//  Created by Max Cobb on 24/04/2021.
//

import Foundation
import RealityKit
import SceneKit
import Combine

// MARK: TextureResource
public extension RealityToolkit {
    /// Load texture from Remote URL and return as a TextureResource in the completion
    /// - Parameters:
    ///   - url: URL for remote file, including file name and extension.
    ///   - destination: Destination path or exact file URL where the image fill will be saved.
    ///   - useCache: Whether any previously downloaded version should be used
    ///   - completion: Result type callback to either get the TextureResource or an Error
    ///
    ///   This method will block the main thread when loading the resource into memory.
    ///   If a local file is passed as the URL, it will not download the file to the end destination, and will not move the item.
    /// - Returns: A TextureResource containing the downloaded image.
    static func loadRemoteTexture(
        contentsOf url: URL, saveTo destination: URL? = nil, useCache: Bool = true
    ) async throws -> TextureResource {
        let localPath = try await RealityToolkit.downloadRemoteFile(
            contentsOf: url, saveTo: destination, useCache: useCache
        )
        return try await self.loadResourceCompletion(contentsOf: localPath)
    }

    internal static func loadResourceCompletion(
        contentsOf url: URL
    ) async throws -> TextureResource {
        return try await MainActor.run { try TextureResource.load(contentsOf: url) }
    }
}

// MARK: Entities
public extension RealityToolkit {
    /// Load model from Remote URL of a USDZ file and return as an Entity in the completion.
    /// This method should be called from the main thread.
    /// - Parameters:
    ///   - url: A file URL representing the file to load.
    ///   - resourceName: A user-defined name to use for network synchronization. See remarks.
    ///   - destination: Destination path or exact file URL where the USDZ/Reality fill will be saved.
    ///   - useCache: Whether the file should be overridden if previously downloaded
    ///   - loadMethod: Method that takes the file URL and filename, and returns a LoadRequest of the entity.
    ///   - completion: Result type callback to either get the Entity or an Error
    /// - Returns: A new Entity containing the contents of the USDZ or Reality file.
    ///
    /// Supported file formats are USD (.usd, .usda, .usdc, .usdz) and Reality File (.reality).
    ///
    /// In order to identify a resource across a network session, the resource needs to have a
    /// unique name. This name is set using `resourceName`. All participants in the network
    /// session need to load the resource and assign the same `resourceName`.
    static func loadEntity(
        contentsOf url: URL, withName resourceName: String? = nil,
        saveTo destination: URL? = nil, useCache: Bool = true,
        using loadMethod: @escaping (@MainActor(_ contentsOf: URL, _: String?) throws -> Entity) = Entity.load
    ) async throws -> Entity {
        let localUrl = try await RealityToolkit.downloadRemoteFile(
            contentsOf: url, saveTo: destination, useCache: useCache
        )
        return try await MainActor.run { try loadMethod(localUrl, resourceName) }
    }

    /// Error type that is returned on failing to load a SCNScene into RealityKit
    enum SceneKitConversionError: Error {
        case writeSceneFailed
    }
    /// Convert an SCNScene to a RealityKit Entity
    /// - Parameters:
    ///   - scene: Scene containing all the SCNNodes to be converted to a RealityKit Entity.
    ///   - loadMethod: Method used to load the Entity from disk. Default is Entity.loadAsync
    ///   - delegate: A delegate object to customize export of external resources used by the scene.
    ///   Pass nil for default export of external resources.
    ///   - completion: Result type callback to either get the Entity or an Error
    /// - Returns: Your new Entity of the exported SCNScene.
    static func loadSCNScene(
        _ scene: SCNScene,
        using loadMethod: @escaping ((_ contentsOf: URL, _: String?) throws -> Entity) = Entity.load,
        delegate: SCNSceneExportDelegate
    ) throws -> Entity {
        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).usdz")
        if !scene.write(to: destinationURL, delegate: delegate) {
            // If we cannot export the scene, return failure
            throw SceneKitConversionError.writeSceneFailed
        }
        return try loadMethod(destinationURL, nil)
    }
}
