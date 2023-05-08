//
//  BoldMaterial.swift
//  
//
//  Created by Max Cobb on 06/05/2023.
//

import RealityKit

@available(macOS 12.0, iOS 15.0, *)
extension PhysicallyBasedMaterial {
    static func BoldMaterial(color: Material.Color?, texture: MaterialParameters.Texture?) -> PhysicallyBasedMaterial {
        assert(!(color == nil && texture == nil), "Color and texture cannot both be nil.")
        var boldMat = self.init()
        boldMat.baseColor = .init(tint: .black)
        boldMat.sheen = .init(tint: .black)
        if let color = color {
            boldMat.emissiveColor = .init(color: color, texture: texture)
        } else {
            boldMat.emissiveColor = .init(texture: texture)
        }
        boldMat.emissiveIntensity = 2
        return boldMat
    }
}
