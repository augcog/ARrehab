//
//  GameSettings.swift
//  ARrehab
//
//  Created by Eric Wang on 2/15/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation

struct GameSettings {
    /// Number of tiles to generate
    var numTiles: Int = 5
    
    /// Play area dimensions (length, width)
    var areaDim: SIMD2<Float> = SIMD2(3, 5)
    
    init() {
    }
    
    init(numTiles: Int?, areaDim: SIMD2<Float>?) {
        self.numTiles = numTiles ?? self.numTiles
        self.areaDim = areaDim ?? self.areaDim
    }
}
