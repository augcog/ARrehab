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
    
    static let gridModel = ModelComponent(mesh: MeshResource.generateBox(size: Tile.TILE_SIZE, cornerRadius: 0.2), materials: [SimpleMaterial(color: SimpleMaterial.Color.red.withAlphaComponent(0.1), isMetallic: false)])
    static let outlineModel = ModelComponent(mesh: MeshResource.generateBox(size: Tile.TILE_SIZE, cornerRadius: 0.2), materials: [SimpleMaterial(color: SimpleMaterial.Color.green, isMetallic: false)])
    
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
            generatePossibleTiles()
            
            self.gridEntity.transform.translation = self.surfaceAnchor.center
        }
    }
    
    //FIXME -- ACCURATELY IDENTIFY NECESSARY BOARD OUTLINE
    func updateBoardOutline(centerTile: Tile) {
        for tile in currentOutline {
            tile.model = TileGrid.gridModel
        }
        self.currentOutline.removeAll()
        
        print("X DISPLACEMENT: ", Int(GameBoard.DIMENSIONS.0 / 2))
        print("Z DISPLACEMENT: ", Int(GameBoard.DIMENSIONS.1 / 2))
        let cornerCoords = Tile.Coordinates(x: centerTile.coords.x + Float(Int(GameBoard.DIMENSIONS.0 / 2)) * Tile.TILE_SIZE.x, z: centerTile.coords.z + Float(Int(GameBoard.DIMENSIONS.1 / 2)) * Tile.TILE_SIZE.z)
        print("COORDS:", cornerCoords)
        
        let cornerTile = self.possibleTiles.first() {coords, tile in
            return TileGrid.isApproxEqual(value1: coords.x, value2: cornerCoords.x, error: 0.1) && TileGrid.isApproxEqual(value1: coords.z, value2: cornerCoords.z, error: 0.1)
        }
        
        if cornerTile == nil {
            print("Invalid center")
            return
        }
        else{
            cornerTile!.value.model = TileGrid.outlineModel
            currentOutline.append(cornerTile!.value)
        }
        
    }
    
}

//Helper Methods
extension TileGrid {
    
    /*
     Generates a tile with the given coordinates
     Adds the tile to the possibleTiles dict. and to the gridEntity
     */
    func generateOneTile(currentX: Float, currentZ: Float) {
        let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ, modelComp: TileGrid.gridModel, adjustTranslation: true)
        self.possibleTiles[newTile.coords] = newTile
        self.gridEntity.addChild(newTile)
    }
    
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
        return abs(value1 - value2) < (0.00 + error) && abs(value1 - value2) > (0.00 - error)
    }
    
}
