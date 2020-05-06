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
    
    var rotated : RotateValue = .north
        
    init(surfaceAnchor: ARPlaneAnchor) {
        self.surfaceAnchor = surfaceAnchor
        
        self.gridEntity = AnchorEntity(anchor: surfaceAnchor)
        self.gridEntity.transform.translation = surfaceAnchor.center
        
        self.generatePossibleTiles()
    }
    
    /*
     Uses the estimated x and z extents of the surface plane to generate an appropriate grid of tiles
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
     Adds the tile to the possibleTiles dictionary (indexed by coordinates)
     and to the gridEntity (with appropriate translation)
     */
    func generateOneTile(currentX: Float, currentZ: Float) {
        let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ, materials: [TileGrid.gridMaterial])
        self.possibleTiles[newTile.coords] = newTile
        self.gridEntity.addChild(newTile)
    }
    
    /*
     Updates the tile grid if the plane has expanded sufficiently
     1) Checks if the new plane is long enough to fit more tiles
     2) If it is, remove all current tiles and regenerate grid to fit
     3) Lastly, adjust translation so grid is re-centered correctly
     */
    func updateBoard(updatedAnc: ARPlaneAnchor) {
        //Update the stored anchor
        self.surfaceAnchor = updatedAnc
        
        if (self.surfaceAnchor.extent.x > self.xLength * 2 + Tile.TILE_SIZE.x || self.surfaceAnchor.extent.z > self.zLength * 2 + Tile.TILE_SIZE.z) {
            
            self.gridEntity.children.removeAll()
            self.possibleTiles.removeAll(keepingCapacity: true)
            
            self.generatePossibleTiles()
            
            self.gridEntity.transform.translation = self.surfaceAnchor.center
        }
    }
    
    /*
     Updates the current board outline if the user is standing at a valid center tile position
     */
    func updateBoardOutline(centerTile: Tile) {
        
        //Clear current outline
        self.clearOutline()
          
        
        //Get an appropriate multiplier for later calculations involving directional offset
        var rotationMultiplier : Float
        switch self.rotated {
        case .north, .east:
            rotationMultiplier = 1.0
        case .south, .west:
            rotationMultiplier = -1.0
        }
        
        //Check for the tiles that would form the upper right and lower left corners of the board
        guard let cornerTiles = findCornerTiles(centerTile: centerTile, rotationMultiplier: rotationMultiplier) else {
            print("Invalid center")
            return
        }
        
        //Based on which direction the board is meant to face, generate an appropriate range to place it "horizontal" or "vertical"
        var xRange : ClosedRange<Int>
        var zRange : ClosedRange<Int>
        switch self.rotated {
        case .north, .south:
            //Makes the x-side of the board the first dimension in the GameBoard DIMENSIONS Tuple
            //and the z the second
            xRange = 0...GameBoard.DIMENSIONS.0 - 1
            zRange = 0...GameBoard.DIMENSIONS.1 - 1
        case .east, .west:
            //Makes the x-side of the board the second dimension in the GameBoard DIMENSIONS Tuple
            //and the z the first
            xRange = 0...GameBoard.DIMENSIONS.1 - 1
            zRange = 0...GameBoard.DIMENSIONS.0 - 1
        }
        
        //Generates the outline of the board
        generateOutline(cornerTile: cornerTiles.0, rotationMultiplier: rotationMultiplier, xRange: xRange, zRange: zRange)
        
    }
    
    
    /*
    Finds the tiles that would form the upper-right and lower-left corners of the board (relative to direction of 'self.rotated'), with the given centerTile
     Returns the tiles in a tuple (Upper Right Corner, Lower Left Corner) if they exist, nil otherwise
     */
    func findCornerTiles(centerTile: Tile, rotationMultiplier: Float) -> (Tile, Tile)? {
        
        let halfBoardX = floor(Double(GameBoard.DIMENSIONS.0) / Double(2))
        let halfBoardZ = floor(Double(GameBoard.DIMENSIONS.1) / Double(2))
        
        var coordTranslation = SIMD2(Tile.TILE_SIZE.x, Tile.TILE_SIZE.z)
        switch self.rotated {
        case .north, .south:
            coordTranslation *= SIMD2<Float>(Float(halfBoardX), Float(-halfBoardZ))
        case .east, .west:
            coordTranslation *= SIMD2<Float>(Float(halfBoardZ), Float(-halfBoardX))
        }
        
        let rightCornerVec = centerTile.coords.coordVec + (rotationMultiplier * coordTranslation)
        let rightCornerTile = self.possibleTiles.first() {coords, tile in
            return TileGrid.isApproxEqual(value1: coords.x, value2: rightCornerVec.x, error: Tile.TILE_SIZE.x / 5) && TileGrid.isApproxEqual(value1: coords.z, value2: rightCornerVec.y, error: Tile.TILE_SIZE.z / 5)
        }
        
        let leftCornerVec = centerTile.coords.coordVec + (-rotationMultiplier * coordTranslation)
        let leftCornerTile = self.possibleTiles.first() {coords, tile in
            return TileGrid.isApproxEqual(value1: coords.x, value2: leftCornerVec.x, error: 0.1) && TileGrid.isApproxEqual(value1: coords.z, value2: leftCornerVec.y, error: 0.1)
        }
        
        if (rightCornerTile != nil && leftCornerTile != nil) {
            return (rightCornerTile!.value, leftCornerTile!.value)
        }
        else {
            return nil
        }
        
    }
    
    /*
     Generates an outline of a game board using the upper-right corner tile of the board, a rotation multiplier (which will determine direction), and a range for the number of tiles in the x and z direction, respectively
     */
    func generateOutline(cornerTile: Tile, rotationMultiplier: Float, xRange: ClosedRange<Int>, zRange: ClosedRange<Int>) {
        for x in xRange {
            for z in zRange {
                //Checks is the tile is part of the border (i.e. should be included in the outline)
                //If this check is removed, the function will instead generate the entire rectangle relative to the corner tile, xRange, and zRange
                if isBorderTile(x: x, z: z, xRange: xRange, zRange: zRange) {
                    let currentCoords = Tile.Coordinates(x: (cornerTile.coords.x) - (rotationMultiplier * Float(x) * Tile.TILE_SIZE.x), z: (cornerTile.coords.z) + (rotationMultiplier * Float(z) * Tile.TILE_SIZE.z))
                    let currentTile = self.possibleTiles[currentCoords]
                    guard currentTile != nil else {
                        self.clearOutline()
                        return
                    }
                    currentTile!.changeMaterials(materials: [TileGrid.outlineMaterial])
                    self.currentOutline.append(currentTile!)
                }
            }
        }
    }
    
    /*
     Clears the current outline by changing all tiles back to the clear material and emptying the list
     */
    func clearOutline() {
        for tile in self.currentOutline {
            tile.changeMaterials(materials: [TileGrid.gridMaterial])
        }
        self.currentOutline.removeAll(keepingCapacity: true)
    }
    
}

//Helper Methods and Nested Data Structures
extension TileGrid {
    
    enum RotateValue {
        case north
        case east
        case south
        case west
    }
    
    /*
     Checks if two values are approximately equal to each other, with the allowed ERROR
     */
    static func isApproxEqual(value1: Float, value2: Float, error: Float) -> Bool {
        return abs(value1 - value2) <= (0.00 + error) && abs(value1 - value2) >= (0.00 - error)
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
    
    /*
     Given x and z values representing the # of tiles offset from the upper right corner of a rectangle with size (xRange + 1) by (zRange + 1), return whether the respective tile lies on the border of the rectangle
     */
    func isBorderTile(x: Int, z: Int, xRange: ClosedRange<Int>, zRange: ClosedRange<Int>) -> Bool {
        return (x == 0 || z == 0 || x == xRange.max() || z == zRange.max())
    }
    
}
