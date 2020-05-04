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

class Player : TileCollider, HasModel, HasAnchoring {
    
    static let PLAYER_COLLISION_GROUP = CollisionGroup(rawValue: 2)
    
    var onTile: Tile!
        
    required init(target: AnchoringComponent.Target) {
        super.init()
        self.collision?.filter.group = Player.PLAYER_COLLISION_GROUP
        self.components[AnchoringComponent] = AnchoringComponent(target)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func onCollisionBegan(tile: Tile) {
        self.onTile = tile
        //self.onTile.changeMaterials(materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        //super.onCollisionBegan(tile: tile)
    }
    
    override func onCollisionEnded(tile: Tile) {
        /*if tile != self.onTile {
            tile.changeMaterials(materials: [SimpleMaterial(color: .clear, isMetallic: false)])
        }*/
        //super.onCollisionEnded(tile: tile)
    }
}

class TileCollider : Entity, HasCollision {
    
    static let defaultCollisionComp = CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.0, height: 0.1, depth: 0.0)], mode: .trigger, filter: CollisionFilter(group: .default, mask: Tile.TILE_COLLISION_GROUP))
    
    var subscriptions: [Cancellable] = []

    required init() {
        super.init()
        self.components[CollisionComponent] = TileCollider.defaultCollisionComp
    }
    
    func addCollision() {
        guard let scene = self.scene else {return}
        self.subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            guard let tile = event.entityB as? Tile else {
                return
            }
            self.onCollisionBegan(tile: tile)
            })
        self.subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            guard let tile = event.entityB as? Tile else {
                return
            }
            self.onCollisionEnded(tile: tile)
            })
    }
    
    func onCollisionBegan(tile: Tile) {
        print("Collision Started")
        print("On Tile: \(tile.tileName)")
    }
    
    func onCollisionEnded(tile: Tile) {
        print("Collision Ended")
        print("On Tile: \(tile.tileName)")
    }
    
}
