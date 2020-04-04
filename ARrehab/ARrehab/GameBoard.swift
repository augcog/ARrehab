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
class GameBoard: ExpressibleByNilLiteral {
    
    var tilesDict: [Tile.Coordinates:Tile] = [:]
    var board: AnchorEntity
    var surfaceAnchor: ARAnchor
    //var games: [Tile:Minigame] = [:]
    
    let colorList : [SimpleMaterial.Color] = [SimpleMaterial.Color.blue, SimpleMaterial.Color.red, SimpleMaterial.Color.green, SimpleMaterial.Color.magenta, SimpleMaterial.Color.purple, SimpleMaterial.Color.cyan, SimpleMaterial.Color.orange]
    
    init(tiles: [Tile], surfaceAnchor: ARAnchor) {
        
        self.surfaceAnchor = surfaceAnchor
        for tile in tiles {
            tilesDict[tile.coords] = tile
        }
       
        board = AnchorEntity(anchor: surfaceAnchor)
        
        generateBoard()
        //assignGames(games: nil)
    }
    
    /*
     init(tiles: [Tile], anchor: ARAnchor, games: [Minigame]) {
        self.tiles = tiles
        //assignGames(games: games)
        generateBoard()
    }
     */
    
    //Nil implementation of GameBoard object
    required init(nilLiteral: ()) {
        self.board = AnchorEntity()
        self.surfaceAnchor = ARAnchor.init(transform: simd_float4x4(diagonal: SIMD4(Float(0), Float(0), Float(0), Float(0))))
    }
    
    /* Assigns every tile in self.tiles a random color and adds it to the self.board AnchorEntity */
    private func generateBoard() {
        for tile in self.tilesDict {
            tile.value.model?.materials = [SimpleMaterial(color: colorList.randomElement()!, isMetallic: false)]
            board.addChild(tile.value)
        }
    }
    
    /*
     private func assignGames(games: [Minigame]) {
        
    }
     */
    
    /* Removes the GameBoard instance's self.board AnchorEntity from the scene */
    func removeBoard() {
        guard self.board.scene != nil else {return}
        self.board.scene?.removeAnchor(self.board)
    }
    
    func generatePath(from: Tile, to: Tile) {
        guard self.tilesDict[from.coords] != nil && self.tilesDict[to.coords] != nil else {return}
        var tilePath: [Tile] = []
    }
    
}
