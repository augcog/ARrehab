//
//  Tile.swift
//  ARrehab
//
//  Created by Eric Wang on 2/15/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit

class Tile: Entity, HasModel, HasCollision {
    let length: Float = 0.3
    let width: Float = 0.3
    var previousTile: Tile?
    var nextTile: Tile?
    
    init(previousTile: Tile?, nextTile: Tile?) {
        self.previousTile = previousTile
        self.nextTile = nextTile
        super.init()
        if self.previousTile != nil {
            if self.previousTile?.nextTile != self {
                self.previousTile = self.nextTile
            }
            setPosition(SIMD3<Float>(self.length, 0.0, self.width), relativeTo: self.previousTile)
        }
    }
    
    init(previousTile: Tile?) {
        self.previousTile = previousTile
        self.nextTile = nil
        super.init()
        setPosition(SIMD3<Float>(self.length, 0.0, self.width), relativeTo: self.previousTile)
    }
    
    init(previousTile: Tile?, nextTile: Tile?, position: SIMD3<Float>) {
        self.previousTile = previousTile
        self.nextTile = nextTile
        super.init()
        setPosition(position, relativeTo: self.anchor)
    }
    
    required init() {
        self.previousTile = nil
        self.nextTile = nil
        super.init()
    }
    
    func setPreviousTile(previousTile: Tile?) {
        self.previousTile = previousTile
    }
    
    func setNextTile(nextTile: Tile?) {
        self.nextTile = nextTile
    }
}
