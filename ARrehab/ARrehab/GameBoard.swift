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
    
    //List of colors for random selection at time of initialization
    static let colorList : [Material] = [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.red, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.green, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.magenta, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.purple, isMetallic: false), SimpleMaterial(color: SimpleMaterial.Color.cyan, isMetallic: false)]
        
    var tilesDict: [Tile.Coordinates:Tile] = [:]
    var board: AnchorEntity
    var surfaceAnchor: ARPlaneAnchor
    var gamesDict: [Tile:Game] = [:]
    
    init(tiles: [Tile], surfaceAnchor: ARPlaneAnchor, games: [Game] = [.movement]) {
       
        self.surfaceAnchor = surfaceAnchor
        
        for tile in tiles {
            tilesDict[tile.coords] = tile
        }
       
        self.board = AnchorEntity(anchor: surfaceAnchor)
        self.board.transform.translation = surfaceAnchor.center
        
        DispatchQueue.main.async {
            self.generateBoard()
        }
        assignGames(games: games)
    }
    
    /* Assigns every tile in self.tiles a random color and adds it to the self.board AnchorEntity */
    private func generateBoard() {
        for tile in self.tilesDict.values {
            //tile.changeMaterials(materials: [GameBoard.colorList.randomElement()!])
            // FIXME load the models directly into tile. Assert that the mesh is actually the size of the model.
            let newTileEntity : ModelEntity = try! Entity.loadModel(named: "Block")
            //newTileEntity.transform.translation = SIMD3<Float>(0,0,0)
            //newTileEntity.transform.scale = Tile.TILE_SIZE / (newTileEntity.model?.mesh.bounds.extents ?? Tile.TILE_SIZE)
            //tile.addChild(newTileEntity, preservingWorldTransform: false)
            tile.model = newTileEntity.model
            tile.scale = Tile.TILE_SIZE / (newTileEntity.model?.mesh.bounds.extents ?? Tile.TILE_SIZE)
            tile.collision?.shapes = [ShapeResource.generateBox(width: tile.model?.mesh.bounds.extents[0] ?? Tile.TILE_SIZE.x, height: 4.0 / tile.transform.scale.y, depth: tile.model?.mesh.bounds.extents[2] ?? Tile.TILE_SIZE.z).offsetBy(translation: SIMD3<Float>(0,2 / tile.transform.scale.y,0))]
            self.board.addChild(tile)
        }
    }
    
    private func assignGames(games: [Game]) {
        for (coord, tile) in tilesDict {
            gamesDict[tile] = games.randomElement()
            if (gamesDict[tile] == nil) {
                continue
            } else {
                let icon = gamesDict[tile]!.icon
                let tileRadius = min(Tile.TILE_SIZE.x, Tile.TILE_SIZE.z)
                // TODO For some reason the scaling isn't quite scaling down as far as I'd like...
                let scale = tileRadius / (icon.model?.mesh.bounds.boundingRadius ?? tileRadius)
                icon.scale = SIMD3<Float>(scale, scale, scale) / tile.scale
                icon.transform.translation.y = Tile.TILE_SIZE.y
                tile.addChild(icon)
            }
        }
    }
    
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
