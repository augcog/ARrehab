//
//  Tile.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 2/23/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import CoreGraphics

class Tile : Entity, HasModel, HasCollision {
    
    static let tileSize = SIMD3<Float>(0.5, 0.01, 0.5)
    
    var isDisplayed: Bool = false
    
    var tileName: String
    let coords : Coordinates
    
    required init(name: String, x: Float, z: Float) {
        self.tileName = name
        
        self.coords = Coordinates(x: x, z: z)
        
        super.init()

        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(size: Tile.tileSize, cornerRadius: 0.2), materials: [SimpleMaterial()])
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.5, height: 4.0, depth: 0.5)], mode: .trigger, filter: .sensor)
        
        self.transform.translation = SIMD3(x, 0.0, z)
        print("Generated Tile: " + name)
    }
   
    convenience init(name: String, x: Float, z: Float, adjustTranslation: Bool) {
        self.init(name: name, x: x, z: z)
        if adjustTranslation {self.transform.translation = Tile.adjustTransformTranslation(coords: self.coords)}
    }
    
    required init() {
        fatalError("Can't instantiate a Tile with no paramaters")
    }
}

extension Tile {
    
    struct Coordinates : Hashable, Equatable {
        var x : Float
        var z : Float
    }
    
    //Adjusts the translation of the tiles so that the appropriate vertex of the tile is at the coordinates it is initialized with (rather than the center)
    static func adjustTransformTranslation(coords: Coordinates) -> SIMD3<Float> {
        let yTranslation: Float = 0
        var xTranslation: Float
        var zTranslation: Float
        
        if coords.x >= 0 {xTranslation = coords.x - (Tile.tileSize.x / 2)}
        else {xTranslation = coords.x + (Tile.tileSize.x / 2)}
        
        if coords.z >= 0 {zTranslation = coords.z - (Tile.tileSize.z / 2)}
        else {zTranslation = coords.z + (Tile.tileSize.z / 2)}
        
        return SIMD3(xTranslation, yTranslation, zTranslation)
    }
    
    func changeColor(color: SimpleMaterial.Color) {
        self.model?.materials = [SimpleMaterial(color: color, isMetallic: true)]
    }
    
}
