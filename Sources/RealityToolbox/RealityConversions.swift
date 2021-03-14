//
//  RealityConversions.swift
//  
//
//  Created by Max Cobb on 04/03/2021.
//

import Foundation
import RealityKit
import SceneKit
import Combine

enum LoadRemoteError: Error {
    case cannotDelete
    case downloadError
}


fileprivate func downloadRemoteFile(contentsOf url: URL, override: Bool = false, completion: @escaping ((Result<URL, Error>) -> Void)) {
    var request = URLRequest(url: url, timeoutInterval: 10)
    let endLocation = FileManager.default.temporaryDirectory
        .appendingPathComponent(url.lastPathComponent)
    if FileManager.default.fileExists(atPath: endLocation.path) {
        if override {
            do {
                try FileManager.default.removeItem(atPath: endLocation.path)
            } catch let err {
                print("Could not remove item: \(err)")
                completion(.failure(LoadRemoteError.cannotDelete))
                return
            }
        } else {

            return
        }
    }
    request.httpMethod = "GET"
    let task = URLSession.shared.downloadTask(
        with: request
    ) { location, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let location = location else {
            completion(.failure(LoadRemoteError.downloadError))
            return
        }
        do {
            try FileManager.default.moveItem(atPath: location.path, toPath: endLocation.path)
        } catch let err {
            print("Could not move item")
            completion(.failure(err))
            return
        }
        completion(.success(endLocation))
    }

    task.resume()
}

// MARK: TextureResource

public extension TextureResource {
    /// Load texture from Remote URL and return as a TextureResource in the completion
    /// - Parameters:
    ///   - url: URL for remote file, including file name and extension
    ///   - override: Whether the file should be overridden if previously downloaded
    ///   - completion: Result type callback to either get the TextureResource or an Error
    static func RTLoadRemoteAsync(
        contentsOf url: URL, override: Bool = false,
        completion: @escaping (Result<TextureResource, Error>) -> Void
    ) {
        downloadRemoteFile(contentsOf: url, override: override) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let endURL):
                self.loadResourceCompletion(contentsOf: endURL, completion: completion)
            }
        }
    }
    private static func loadResourceCompletion(contentsOf url: URL, completion: @escaping (Result<TextureResource, Error>) -> Void) {
        _ = TextureResource.loadAsync(contentsOf: url).sink(
            receiveCompletion: { loadCompletion in
              // Added this switch just as an example
              switch loadCompletion {
                case .failure(let loadErr):
                    completion(.failure(loadErr))
                case .finished:
                  print("entity loaded without errors")
              }
            }, receiveValue: { textureResource in
                completion(.success(textureResource))
            }
        )
    }
}

// MARK: Models

public extension Entity {
    /// Load model from Remote URL of a USDZ file and return as an Entity in the completion
    /// - Parameters:
    ///   - url: URL for remote file, including file name and extension
    ///   - override: Whether the file should be overridden if previously downloaded
    ///   - completion: Result type callback to either get the Entity or an Error
    static func RTLoadRemoteAsync(contentsOf url: URL, override: Bool = false, completion: @escaping (Result<Entity, Error>) -> Void) {
        downloadRemoteFile(contentsOf: url, override: override) { result in
            switch result {
            case .success(let endURL):
                Entity.loadModelCompletion(contentsOf: endURL, completion: completion)
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    private static func loadModelCompletion(contentsOf url: URL, completion: @escaping (Result<Entity, Error>) -> Void) {
        _ = Entity.loadAsync(contentsOf: url).sink(
            receiveCompletion: { loadCompletion in
              // Added this switch just as an example
              switch loadCompletion {
                case .failure(let loadErr):
                    completion(.failure(loadErr))
                case .finished:
                  print("entity loaded without errors")
              }
            }, receiveValue: { entity in
                completion(.success(entity))
            }
        )
    }

    enum SceneKitConversionError: Error {
        case writeSceneFailed
    }
    /// Convert an SCNScene to a RealityKit Entity
    /// - Parameters:
    ///   - scene: Scene containing all the SCNNodes to be converted to a RealityKit Entity.
    ///   - delegate: A delegate object to customize export of external resources used by the scene. Pass nil for default export of external resources.
    ///   - completion: Result type callback to either get the Entity or an Error
    static func RTLoadScene(
        from scene: SCNScene,
        delegate: SCNSceneExportDelegate,
        completion: @escaping (Result<Entity, Error>) -> Void
    ) {
        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).usdz")
        if scene.write(to: destinationURL, delegate: delegate) {
            self.loadModelCompletion(contentsOf: destinationURL, completion: completion)
        } else {
            completion(.failure(SceneKitConversionError.writeSceneFailed))
        }
    }
}
