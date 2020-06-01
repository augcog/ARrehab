//
//  Board.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 4/3/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import ARKit


 /*
 Instance variables:
    tiles: List of all Tile objects contained in the game board
    games: Dictionary consisting of Tile-Minigame value pairs
    board: ModelEntity representing the board, to be displayed in the scene
 Instance methods:
    init(tiles: [Tile]): Initializes a new GameBoard object instance from a list of Tiles
        - Generates the physical entity to be displayed in the scene
        - Assigns minigames to every tile
    init(tiles: [Tile], games: [Minigame]): Optional init, initializes a GameBoard object with a predefined list of games (*Length of games must equal # of tiles)
    generateBoard():
        - Adds all of the tiles in self.tiles to the board AnchorEntity (mutates self.board)
        - Sets any initial aesthetic aspects of the tiles
    removeBoard():
        - Removes the GameBoard instance's board entity from the scene
    assignGames()
        - Assigns Minigames to each tile in a list of tiles (mutates self.games)
*/


///GameBoard object represents the game board. It holds references to all tiles on the board, as well as the minigames assigned to each tile.

class GameBoard {
    
    //Dimension of the board (in tiles) (x, z)
    static let DIMENSIONS = (3, 5)
    
    //Minimum extents for a valid game board (in meters)
    //Does not distinguish between global x and z directions
    static let EXTENT1 : Float = Float(GameBoard.DIMENSIONS.0) * Tile.TILE_SIZE.x
    static let EXTENT2 : Float = Float(GameBoard.DIMENSIONS.1) * Tile.TILE_SIZE.z
    
    var tilesDict: [Tile.Coordinates:Tile] = [:]
    var board: AnchorEntity
    // TODO Considier making these dicts attributes of the tiles instead.
    var gamesDict: [Tile:Game] = [:]
    var iconDict: [Tile:Entity] = [:]
    
    var center : Tile.Coordinates
    
    init(tiles: [Tile], surfaceAnchor: AnchorEntity, center: Tile.Coordinates, games: [Game] = [.trace]) {
        
        for tile in tiles {
            tilesDict[tile.coords] = tile
        }
       
        self.board = surfaceAnchor
        self.center = center
        
        DispatchQueue.main.async {
            self.generateBoard()
            self.assignGames(games: games)
        }
    }
    
    ///Adds every tile in the gameboard's 'tilesDict' to to the 'board' AnchorEntity, modifying aesthetics as desired
    private func generateBoard() {
        for tile in self.tilesDict.values {
            //tile.changeMaterials(materials: [GameBoard.colorList.randomElement()!])
            // FIXME load the models directly into tile. Assert that the mesh is actually the size of the model.
            let newTileEntity : ModelEntity = try! Entity.loadModel(named: "Block")
            tile.model = newTileEntity.model
            tile.scale = Tile.TILE_SIZE / (newTileEntity.model?.mesh.bounds.extents ?? Tile.TILE_SIZE)
            tile.collision?.shapes = [ShapeResource.generateBox(width: tile.model?.mesh.bounds.extents[0] ?? Tile.TILE_SIZE.x, height: 4.0 / tile.transform.scale.y, depth: tile.model?.mesh.bounds.extents[2] ?? Tile.TILE_SIZE.z).offsetBy(translation: SIMD3<Float>(0,2 / tile.transform.scale.y,0))]
            self.board.addChild(tile)
        }
    }
    
    ///Randomly assign games to all tiles on the board (possibility of no game)
    private func assignGames(games: [Game]) {
        var gameNum = 0
        for (coord, tile) in tilesDict {
            if (isCorner(coord: coord)) {
                gamesDict[tile] = games[gameNum % games.count]
                gameNum += 1
            } else {
                gamesDict[tile] = nil
            }
            if (gamesDict[tile] == nil) {
                continue
            } else {
                let icon = gamesDict[tile]!.icon
                let tileRadius = min(Tile.TILE_SIZE.x, Tile.TILE_SIZE.z) / 2
                // TODO For some reason the scaling isn't quite scaling down as far as I'd like...
                let scale = tileRadius / (icon.model?.mesh.bounds.boundingRadius ?? tileRadius)
                icon.scale = SIMD3<Float>(scale, scale, scale) / tile.scale
                icon.transform.translation.y = Tile.TILE_SIZE.y
                tile.addChild(icon)
                iconDict[tile] = icon
            }
        }
    }
    
    func isCorner(coord: Tile.Coordinates) -> Bool{
        let local = coord.localVec(center: center)
        let x = (GameBoard.DIMENSIONS.0 - 1) / 2
        let z = (GameBoard.DIMENSIONS.1 - 1) / 2
        return (abs(local.x) == x && abs(local.y) == z || abs(local.x) == z && abs(local.y) == x)
        
    }
    
    ///Adds the self.board AnchorEntity to the scene
    func addBoardToScene(arView: ARView) {
        arView.scene.addAnchor(self.board)
    }
    
    ///Removes the GameBoard instance's self.board AnchorEntity from the scene
    func removeBoard() {
        guard self.board.scene != nil else {return}
        self.board.scene?.removeAnchor(self.board)
    }
    
    ///Removes the minigame assigned to the given tile
    func removeGame(_ tile: Tile) {
        self.gamesDict[tile] = nil
        tile.removeChild(iconDict[tile] ?? Entity())
    }
    
}
