//
//  DownloadTests.swift
//  
//
//  Created by Max Cobb on 12/06/2022.
//

import XCTest
@testable import RealityToolkit
import Foundation
import RealityKit
import RealityFoundation
import Combine

final class Download_Tests: XCTestCase {

    var downloadsFolder: URL = {
        let fm = FileManager.default
        let folder = fm.temporaryDirectory

        var isDirectory: ObjCBool = false
        let fileEx = fm.fileExists(atPath: folder.path, isDirectory: &isDirectory)
        if !(fileEx) {
            try! fm.createDirectory(at: folder, withIntermediateDirectories: false, attributes: nil)
        }
        return folder
    }()

    func testDownloadImg() async throws {
        let saveToParam = self.downloadsFolder.appendingPathComponent("test_image.png")
        let testImg = "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-suite-everything-you-need-know-about-google-newest-0.png"
        let remoteFileLoaded = try await RealityToolkit.downloadRemoteFile(
            contentsOf: URL(string: testImg)!,
            saveTo: saveToParam,
            useCache: false)
        XCTAssertEqual(remoteFileLoaded, saveToParam, "Saved location and saveToParam to not match.")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: remoteFileLoaded.path),
            "File not downloaded"
        )

        let texResource = try await RealityToolkit.loadRemoteTexture(contentsOf: saveToParam)

        XCTAssertEqual(texResource.width, 1024, "Width is not 1024, is instead: \(texResource.width)")
        XCTAssertEqual(texResource.width, texResource.height, "Width and Height do not match. Height: \(texResource.height)")
    }

    func testDownloadImgFail() async throws {
        do {
            _ = try await RealityToolkit.downloadRemoteFile(
                contentsOf: URL(string: "https://i-n-v-a-l-i-d-u-r-l.comination/123/no-image-here.jpg")!
            )
        } catch let err as URLError {
            XCTAssertTrue(err.errorCode == URLError.Code.cannotFindHost.rawValue, "Wrong kind of error coming back")
            return
        }
        XCTFail("The download should have failed")
    }

    func testDownloadUsdz() async throws {
        let testImg = "https://developer.apple.com/augmented-reality/quick-look/models/retrotv/tv_retro.usdz"
        let remoteFileLoaded = try await RealityToolkit.downloadRemoteFile(
            contentsOf: URL(string: testImg)!,
            saveTo: self.downloadsFolder,
            useCache: false)
        XCTAssertEqual(remoteFileLoaded, self.downloadsFolder.appendingPathComponent("tv_retro.usdz"), "Saved location and saveToParam to not match.")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: remoteFileLoaded.path),
            "File not downloaded"
        )
        let retroTV = try await RealityToolkit.loadEntity(contentsOf: URL(string: testImg)!, using: Entity.load)

        XCTAssertTrue(
            retroTV.visualBounds(relativeTo: nil).boundingRadius > 0.5,
            "Model not loaded correctly"
        )
    }
}

