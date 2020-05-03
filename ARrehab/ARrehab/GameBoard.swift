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
    
    //Minimum extents for a valid game board (in meters)
    //Does not distinguish between x and z directions
    static let EXTENT1 : Float = 2.0
    static let EXTENT2 : Float = 3.0
    
    //Dimension of the board (in tiles)
    static let DIMENSIONS = (3, 5)
    
    //List of colors for random selection at time of initialization
    static let colorList : [Material] = [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.red, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.green, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.magenta, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.purple, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.cyan, isMetallic: false)]
    
    static let rkTileScene = try? TileScene.loadScene()
        
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
    
    /* Assigns every tile in self.tiles a random color and adds it to the self.board AnchorEntity */
    private func generateBoard() {
        for tile in self.tilesDict.values {
            //tile.changeMaterials(materials: [GameBoard.colorList.randomElement()!])
            let newTileEntity = try? TileScene.loadScene().findEntity(named: "tile")
            newTileEntity?.transform.translation = SIMD3<Float>(0,0,0)
            tile.addChild(newTileEntity!, preservingWorldTransform: false)
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
