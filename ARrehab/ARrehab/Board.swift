//
//  Board.swift
//  ARrehab
//
//  Created by Eric Wang on 2/14/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit

class Board {
    var tiles: [Tile]
    var length: Float
    var width: Float
    init(numTiles: Int, length: Float, width: Float) {
        var previousTile: Tile? = nil
        self.tiles = Array()
        for i in 0 ..< numTiles {
            self.tiles[i] = Tile(previousTile: previousTile)
            previousTile = self.tiles[i]
        }
        self.length = length
        self.width = width
    }
    
    getPath(startTile: Tile, endTile: Tile) {
        
    }
}
