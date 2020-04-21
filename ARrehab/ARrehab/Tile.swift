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
    
    //Class attributes
    static let TILE_SIZE = SIMD3<Float>(0.5, 0.01, 0.5)
   
    static let defaultTileModel = ModelComponent(mesh: MeshResource.generateBox(size: Tile.TILE_SIZE, cornerRadius: 0.2), materials: [SimpleMaterial()])
    static let defaultCollisionComp = CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.5, height: 4.0, depth: 0.5)], mode: .trigger, filter: .sensor)
    
    //Instance variables
    var tileName: String
    let coords : Coordinates
    
    
    //Default initializer: Uses default model and collision componenets, does not adjust translation
    required init(name: String, x: Float, z: Float) {
        self.tileName = name
        
        self.coords = Coordinates(x: x, z: z)
        
        super.init()

        self.components[ModelComponent] = Tile.defaultTileModel
        self.components[CollisionComponent] = Tile.defaultCollisionComp
        
        self.transform.translation = SIMD3(x, 0.0, z)
        print("Generated Tile: " + name)
    }
    
    //Optional initializer: Allows specification of custom model components and translation adjustment
    init(name: String, x: Float, z: Float, modelComp: ModelComponent = Tile.defaultTileModel, adjustTranslation: Bool = false) {
        self.tileName = name
        
        self.coords = Coordinates(x: x, z: z)
        
        super.init()

        self.components[CollisionComponent] = Tile.defaultCollisionComp
        self.components[ModelComponent] = modelComp
        
        if adjustTranslation {
            print("Adjusting")
            self.transform.translation = Tile.adjustTransformTranslation(coords: self.coords)
        }
        else {
            self.transform.translation = SIMD3(x, 0.0, z)
        }
        
        print("Generated Tile: " + name)
    }
    
    required init() {
        fatalError("Can't instantiate a Tile with no paramaters")
    }
}


//Nested data types and convenience methods
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
        
        if coords.x >= 0 {xTranslation = coords.x - (Tile.TILE_SIZE.x / 2)}
        else {xTranslation = coords.x + (Tile.TILE_SIZE.x / 2)}
        
        if coords.z >= 0 {zTranslation = coords.z - (Tile.TILE_SIZE.z / 2)}
        else {zTranslation = coords.z + (Tile.TILE_SIZE.z / 2)}
        
        return SIMD3(xTranslation, yTranslation, zTranslation)
    }
    
    func changeColor(color: SimpleMaterial.Color) {
        self.model?.materials = [SimpleMaterial(color: color, isMetallic: true)]
    }
    
}
