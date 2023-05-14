//
//  BoldMaterial.swift
//  
//
//  Created by Max Cobb on 06/05/2023.
//

import RealityKit
#if canImport(AppKit)
import AppKit.NSColor
#elseif canImport(UIKit.UIColor)
import UIKit.UIColor
#endif

/// A RealityKit Material where colors really pop, and do not respond to lighting.
public typealias BoldMaterial = PhysicallyBasedMaterial

public extension BoldMaterial {
    /// An initialiser for making a ``BoldMaterial``. BoldMaterial is essentially just a PhysicallyBasedMaterial,
    /// but with some properties that make non-responsive to lighting, and the colours pop more vividly than an UnlitMaterial.
    /// - Parameters:
    ///   - color: Color to set for the Bold material.
    init(color: Material.Color) {
        self.init(color: color, texture: nil)
    }

    /// An initialiser for making a ``BoldMaterial``. BoldMaterial is essentially just a PhysicallyBasedMaterial,
    /// but with some properties that make non-responsive to lighting, and the colours pop more vividly than an UnlitMaterial.
    /// - Parameters:
    ///   - texture: Texture to set for the Bold material.
    init(texture: MaterialParameters.Texture) {
        self.init(color: nil, texture: texture)
    }
    internal init(color: Material.Color?, texture: MaterialParameters.Texture?) {
        self.init()
        self.baseColor = .init(tint: .black)
        self.sheen = .init(tint: .black)
        if let color = color {
            self.emissiveColor = .init(color: color, texture: texture)
        } else {
            self.emissiveColor = .init(texture: texture)
        }
        self.emissiveIntensity = 2
    }
}
