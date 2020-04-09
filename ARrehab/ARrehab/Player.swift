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
    
    var onTile: Tile!
        
    required init(target: AnchoringComponent.Target) {
        super.init()
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 2, height: 2, depth: 2), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false)])
        self.components[AnchoringComponent] = AnchoringComponent(target)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func onCollisionBegan(tile: Tile) {
        self.onTile = tile
        super.onCollisionBegan(tile: tile)
    }
    
    override func onCollisionEnded(tile: Tile) {
        if self.onTile == tile {
            self.onTile = nil
        }
        super.onCollisionEnded(tile: tile)
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
        tile.model?.materials = [
            SimpleMaterial(color: .yellow, isMetallic: false)
        ]
        if (!tile.isDisplayed) {tile.isDisplayed = true}
    }
    
    func onCollisionEnded(tile: Tile) {
        print("Collision Ended")
        print("On Tile: \(tile.tileName)")
        if (tile.isDisplayed) {
            tile.model?.materials = [
                SimpleMaterial(color: .green, isMetallic: false)
            ]
        } else {
            tile.model?.materials = [
                SimpleMaterial(color: .clear, isMetallic: false)
            ]
        }
    }
    
}
