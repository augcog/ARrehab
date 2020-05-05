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
    
    enum RotateValue {
        case north
        case east
        case south
        case west
    }
    var rotated : RotateValue = .north
        
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
        
        var currentX = (xExtent/2) - xSize/2
        var currentZ = (zExtent/2) - zSize/2
        
        //Generate the tiles
        while abs(currentX) <= ((xExtent/2) - xSize/2) {
            while abs(currentZ) <= ((zExtent/2 - zSize/2)) {
                self.generateOneTile(currentX: currentX, currentZ: currentZ)
                currentZ -= zSize
            }
            currentZ = (zExtent/2) - zSize/2
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
        let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ, materials: [TileGrid.gridMaterial], adjustTranslation: false)
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
        
        let halfBoardX = floor(Double(GameBoard.DIMENSIONS.0) / Double(2))
        let halfBoardZ = floor(Double(GameBoard.DIMENSIONS.1) / Double(2))
                
        var rotationMultiplier : Float
        switch self.rotated {
        case .north, .east:
            rotationMultiplier = 1.0
        case .south, .west:
            rotationMultiplier = -1.0
        }
        
        //Find the tile that would form the upper-right corner of the board (relative to direction of 'self.rotated'), with the given centerTile
        var cornerCoords : Tile.Coordinates
        var coordTranslation = SIMD2(Tile.TILE_SIZE.x, Tile.TILE_SIZE.z)
        switch self.rotated {
        case .north, .south:
            coordTranslation *= SIMD2<Float>(Float(halfBoardX), Float(-halfBoardZ))
        case .east, .west:
            coordTranslation *= SIMD2<Float>(Float(halfBoardZ), Float(-halfBoardX))
        }
        let newCoordVec = centerTile.coords.coordVec + (rotationMultiplier * coordTranslation)
        cornerCoords = Tile.Coordinates(x: newCoordVec.x, z: newCoordVec.y)
        /*switch self.rotated {
        case .north, .south:
            cornerCoords = Tile.Coordinates(x: centerTile.coords.x + (Float(halfBoardX) * rotationMultiplier * Tile.TILE_SIZE.x), z: centerTile.coords.z - (Float(halfBoardZ) * rotationMultiplier * Tile.TILE_SIZE.z))
        case .east, .west:
            cornerCoords = Tile.Coordinates(x: centerTile.coords.x + (Float(halfBoardZ) * rotationMultiplier * Tile.TILE_SIZE.x), z: centerTile.coords.z - (Float(halfBoardX) * rotationMultiplier * Tile.TILE_SIZE.z))
        }*/
        let cornerTile = self.possibleTiles.first() {coords, tile in
            return TileGrid.isApproxEqual(value1: coords.x, value2: cornerCoords.x, error: 0.1) && TileGrid.isApproxEqual(value1: coords.z, value2: cornerCoords.z, error: 0.1)
        }
        guard cornerTile != nil else {
            print("Invalid center")
            return
        }
        cornerTile!.value.changeMaterials(materials: [SimpleMaterial(color: .green, isMetallic: false)])
        self.currentOutline.append(cornerTile!.value)
        
        var xRange : ClosedRange<Int>
        var zRange : ClosedRange<Int>
        switch self.rotated {
        case .north, .south:
            xRange = 0...GameBoard.DIMENSIONS.0 - 1
            zRange = 0...GameBoard.DIMENSIONS.1 - 1
        case .east, .west:
            xRange = 0...GameBoard.DIMENSIONS.1 - 1
            zRange = 0...GameBoard.DIMENSIONS.0 - 1
        }
        
        for x in xRange {
            for z in zRange {
                let currentCoords = Tile.Coordinates(x: (cornerTile!.key.x) - (rotationMultiplier * Float(x) * Tile.TILE_SIZE.x), z: (cornerTile!.key.z) + (rotationMultiplier * Float(z) * Tile.TILE_SIZE.z))
                let currentTile = self.possibleTiles[currentCoords]
                guard currentTile != nil else {
                    print("TILE DOESN'T EXIST")
                    self.clearOutline()
                    return
                }
                currentTile!.changeMaterials(materials: [TileGrid.outlineMaterial])
                self.currentOutline.append(currentTile!)
            }
        }
        cornerTile?.value.changeMaterials(materials: [SimpleMaterial(color: .blue, isMetallic: false)])
    }
    
    func clearOutline() {
        for tile in self.currentOutline {
            tile.changeMaterials(materials: [TileGrid.gridMaterial])
        }
        self.currentOutline.removeAll(keepingCapacity: true)
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
