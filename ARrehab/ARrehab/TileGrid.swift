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
    
    /*
    Variables to aid in manual board generation
    var selectedTiles: [Tile] = []
    var tileCount: Int = 0
     */
        
    init(surfaceAnchor: ARPlaneAnchor) {
        self.surfaceAnchor = surfaceAnchor
        
        self.gridEntity = AnchorEntity(anchor: surfaceAnchor)
        self.gridEntity.transform.translation = surfaceAnchor.center
        
        self.generatePossibleTiles()
    }
    
    /*
     Uses the estimated x and z extents of the surface plane to generate an appropriate amount of tiles with adjusted translations (so that tiles don't extend past edges of plane)
    */
    func generatePossibleTiles() {
        let xExtent = self.surfaceAnchor.extent.x
        let zExtent = self.surfaceAnchor.extent.z
        
        let xSize = Tile.tileSize.x
        let zSize = Tile.tileSize.z
        
        var currentX = xExtent/2
        var currentZ = zExtent/2
        
        DispatchQueue.main.async {
            while abs(currentX) <= xExtent/2 {
                while abs(currentZ) <= zExtent/2 {
                    self.generateOneTile(currentX: currentX, currentZ: currentZ)
                    currentZ -= zSize
                }
                currentZ = zExtent/2
                currentX -= xSize
            }
        }
    }
    
    func generateOneTile(currentX: Float, currentZ: Float) {
        let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ, adjustTranslation: true)
        newTile.changeColor(color: SimpleMaterial.Color.red.withAlphaComponent(0.1))
        self.possibleTiles.append(newTile)
        self.gridEntity.addChild(newTile)
    }
    
}
