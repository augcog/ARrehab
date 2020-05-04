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
    
    static let gridMaterial = SimpleMaterial(color: SimpleMaterial.Color.red.withAlphaComponent(0.1), isMetallic: false)
    static let outlineMaterial = SimpleMaterial(color: SimpleMaterial.Color.green, isMetallic: false)
    
    var surfaceAnchor : ARPlaneAnchor
    var gridEntity : AnchorEntity
    
    var possibleTiles : [Tile.Coordinates: Tile] = [:]
    var currentOutline : [Tile] = []
    
    var xLength: Float = 0.0
    var zLength: Float = 0.0
        
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
        
        let xSize = Tile.TILE_SIZE.x
        let zSize = Tile.TILE_SIZE.z
        
        var currentX = xExtent/2
        var currentZ = zExtent/2
        
        //Generate the tiles
        while abs(currentX) <= xExtent/2 {
            while abs(currentZ) <= zExtent/2 {
                self.generateOneTile(currentX: currentX, currentZ: currentZ)
                currentZ -= zSize
            }
            currentZ = zExtent/2
            currentX -= xSize
        }
        
        self.xLength = getMaxX().0.x
        self.zLength = getMaxZ().0.z
    }
    
    /*
     Generates a tile with the given coordinates
     Adds the tile to the possibleTiles dict. and to the gridEntity
     */
    func generateOneTile(currentX: Float, currentZ: Float) {
        let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ, materials: [TileGrid.gridMaterial], adjustTranslation: true)
        self.possibleTiles[newTile.coords] = newTile
        self.gridEntity.addChild(newTile)
    }
    
    /*
     Updates the tile grid if the plane has expanded sufficiently
     */
    func updateBoard(updatedAnc: ARPlaneAnchor) {
        //Update the stored anchor
        self.surfaceAnchor = updatedAnc
        
        /*
         Check if the new plane is long enough to fit more tiles
         If so, remove all current tiles and regenerate grid to fit
         Lastly, adjust translation so grid is re-centered correctly
         */
        if (self.surfaceAnchor.extent.x > self.xLength * 2 + Tile.TILE_SIZE.x || self.surfaceAnchor.extent.z > self.zLength * 2 + Tile.TILE_SIZE.z) {
            
            self.gridEntity.children.removeAll()
            self.generatePossibleTiles()
            
            self.gridEntity.transform.translation = self.surfaceAnchor.center
        }
    }
    
    //TODO -- IMPLEMENT DIRECTIONAL KNOWLEDGE
    func updateBoardOutline(centerTile: Tile) {
        
        //Clear current outline
        self.clearOutline()
        
        //Find the tile that would form the upper-right corner of the board, with the given centerTile
        let cornerCoords = Tile.Coordinates(x: centerTile.coords.x + (1 * Tile.TILE_SIZE.x), z: centerTile.coords.z + (2 * Tile.TILE_SIZE.z))
        
        let cornerTile = self.possibleTiles.first() {coords, tile in
            return TileGrid.isApproxEqual(value1: coords.x, value2: cornerCoords.x, error: 0.1 / Tile.SCALE) && TileGrid.isApproxEqual(value1: coords.z, value2: cornerCoords.z, error: 0.1 / Tile.SCALE)
        }
        
        if cornerTile == nil {
            print("Invalid center")
            return
        }
        
        else {
            for i in 0...(GameBoard.DIMENSIONS.0 - 1) {
                for c in 0...(GameBoard.DIMENSIONS.1 - 1) {
                    if (i == 0 || i == (GameBoard.DIMENSIONS.0 - 1) || c == 0 || c == (GameBoard.DIMENSIONS.1 - 1)) {
                        let currentCoords = Tile.Coordinates(x: (cornerTile?.key.x)! - (Float(i) * Tile.TILE_SIZE.x), z: (cornerTile?.key.z)! - (Float(c) * Tile.TILE_SIZE.z))
                        guard let currentTile = self.possibleTiles[currentCoords] else {
                            print("TILE DOESNT EXIST")
                            self.clearOutline()
                            return
                        }
                        currentTile.changeMaterials(materials: [TileGrid.outlineMaterial])
                        self.currentOutline.append(currentTile)
                    }
                }
            }
        }
        
    }
    
    func clearOutline() {
        for tile in self.currentOutline {
            tile.changeMaterials(materials: [TileGrid.gridMaterial])
        }
        self.currentOutline.removeAll()
    }
    
}

//Helper Methods
extension TileGrid {
    
    /*
     getMaxX() and getMaxZ() return the tiles with the largest X and Z coordinates,
        respectively
     */
    func getMaxX() -> (Tile.Coordinates, Tile) {
        return self.possibleTiles.max(by:) {tile1, tile2 in
            return tile1.key.x < tile2.key.x
            }!
    }
    
    func getMaxZ() -> (Tile.Coordinates, Tile) {
        return self.possibleTiles.max(by:) {tile1, tile2 in
            return tile1.key.z < tile2.key.z
        }!
    }
    
    static func isApproxEqual(value1: Float, value2: Float, error: Float) -> Bool {
        return abs(value1 - value2) <= (0.00 + error) && abs(value1 - value2) >= (0.00 - error)
    }
    
}
