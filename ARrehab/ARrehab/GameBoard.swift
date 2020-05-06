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
 GameBoard object represents the game board. It holds references to all tiles on the board, as well as the minigames assigned to each tile. It contains methods for board object generation, board object deletion, and path generation.
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
    generatePath(from: Tile, to: Tile) -> [Tile]:
        - Returns a list of adjacent tiles that connect 'from' to 'to', or nil if such a path does not exist
    assignGames()
        - Assigns Minigames to each tile in a list of tiles (mutates self.games)
*/
class GameBoard {
    
    //Dimension of the board (in tiles) (x, z)
    static let DIMENSIONS = (3, 5)
    
    //Minimum extents for a valid game board (in meters)
    //Does not distinguish between global x and z directions
    static let EXTENT1 : Float = Float(GameBoard.DIMENSIONS.0) * Tile.TILE_SIZE.x
    static let EXTENT2 : Float = Float(GameBoard.DIMENSIONS.1) * Tile.TILE_SIZE.z
    
    var tilesDict: [Tile.Coordinates:Tile] = [:]
    var board: AnchorEntity
    var surfaceAnchor: ARPlaneAnchor
    //var games: [Tile:Minigame] = [:]
    
    init(tiles: [Tile], surfaceAnchor: ARPlaneAnchor) {
        
        self.surfaceAnchor = surfaceAnchor
        
        for tile in tiles {
            tilesDict[tile.coords] = tile
        }
       
        self.board = AnchorEntity(anchor: surfaceAnchor)
        self.board.transform.translation = surfaceAnchor.center
        
        DispatchQueue.main.async {
            self.generateBoard()
        }
        //assignGames(games: nil)
    }
    
    /*
     init(tiles: [Tile], anchor: ARAnchor, games: [Minigame]) {
        self.tiles = tiles
        //assignGames(games: games)
        generateBoard()
    }
     */
    
    /* Adds every tile in self.tilesDict to the self.board AnchorEntity, modifying aesthetics as desired */
    private func generateBoard() {
        for tile in self.tilesDict.values {
            // TODO Design choice should we load the block as a model for the tile or as a separate entity?
            let newTileEntity : ModelEntity = try! Entity.loadModel(named: "Block")
            newTileEntity.transform.translation = SIMD3<Float>(0,0,0)
            newTileEntity.transform.scale = Tile.TILE_SIZE / (newTileEntity.model?.mesh.bounds.extents ?? Tile.TILE_SIZE)
            tile.addChild(newTileEntity, preservingWorldTransform: false)
            tile.model = nil
            self.board.addChild(tile)
        }
    }
    
    /*
     private func assignGames(games: [Minigame]) {
        
    }
     */
    
    func addBoardToScene(arView: ARView) {
        print("Trying")
        arView.scene.addAnchor(self.board)
    }
    
    /* Removes the GameBoard instance's self.board AnchorEntity from the scene */
    func removeBoard() {
        guard self.board.scene != nil else {return}
        self.board.scene?.removeAnchor(self.board)
    }
    
}
