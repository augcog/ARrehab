//
//  TileGrid.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 4/12/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import ARKit
import RealityKit

class TileGrid {
    
    var surfaceAnchor: ARPlaneAnchor
    var gridEntity: AnchorEntity
    
    var possibleTiles: [Tile] = []
    var selectedTiles: [Tile] = []
    var tileCount: Int = 0
    
    init(surfaceAnchor: ARPlaneAnchor) {
        self.surfaceAnchor = surfaceAnchor
        self.gridEntity = AnchorEntity(anchor: surfaceAnchor)
        generatePossibleTiles()
    }
    
    func generatePossibleTiles() {
        let xExtent = self.surfaceAnchor.extent.x
        let zExtent = self.surfaceAnchor.extent.z
        
        let xSize = Tile.tileSize.x
        let zSize = Tile.tileSize.z
        
        var currentX = xExtent/2
        var currentZ = zExtent/2
        
        while abs(currentX) <= xExtent/2 {
            while abs(currentZ) <= zExtent/2 {
                let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ, adjustTranslation: true)
                newTile.model?.materials = [SimpleMaterial.init(color: SimpleMaterial.Color.clear, isMetallic: true)]
                self.possibleTiles.append(newTile)
                self.gridEntity.addChild(newTile)
                currentZ -= zSize
            }
            currentZ = zExtent/2
            currentX -= xSize
        }
    }
    
}
