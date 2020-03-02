//
//  Player.swift
//  ARrehab
//
//  Created by Eric Wang on 2/24/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import Combine

class Player : TileCollider, HasModel, HasAnchoring{
        
    required init(target: AnchoringComponent.Target) {
        super.init()
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 2, height: 2, depth: 2), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false)])
        self.components[AnchoringComponent] = AnchoringComponent(target)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class GameAvatar: Entity, HasModel {
    required init() {
        super.init()
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 0.3, height: 0.3, depth: 0.3), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false)])
    }
    
    func changeTile(tile: Tile?) {
        self.setParent(tile, preservingWorldTransform: false)
    }
    
}

class PlayerAvatar: TileCollider, HasModel {
    var onTile: Tile? = nil
    var gameAvatar: GameAvatar
    
    required init(gameAvatar: GameAvatar) {
        self.gameAvatar = gameAvatar
        super.init()
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 0.0, height: 0.0, depth: 0.0), materials: [SimpleMaterial(color: SimpleMaterial.Color.yellow, isMetallic: false)])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func onCollisionBegan(tile: Tile) {
        self.onTile = tile
        self.gameAvatar.changeTile(tile: self.onTile)
    }
    
    override func onCollisionEnded(tile: Tile) {
        if self.onTile == tile {
            self.onTile = nil
            self.gameAvatar.changeTile(tile: nil)
        }
    }
}

    
class TileCollider : Entity, HasCollision {
    
    var subscriptions: [Cancellable] = []

    required init() {
        super.init()
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.1, height: 0.1, depth: 0.1)], mode: .trigger, filter: .sensor)
    }
    
    func addCollision() {
        guard let scene = self.scene else {return}
        subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            print("Collision Started")
            guard let tile = event.entityB as? Tile else {
                return
            }
            self.onCollisionBegan(tile: tile)
            
        })
        subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            print("Collision Ended")
            guard let tile = event.entityB as? Tile else {
                return
            }
            self.onCollisionEnded(tile: tile)

        })
    }
    
    func onCollisionBegan(tile: Tile) {
        print("On Tile: \(tile.tileName)")
        tile.model?.materials = [
            SimpleMaterial(color: .red, isMetallic: false)
        ]
    }
    
    func onCollisionEnded(tile: Tile) {
        print("On Tile: \(tile.tileName)")
        tile.model?.materials = [
            SimpleMaterial(color: .green, isMetallic: false)
        ]
    }
}
