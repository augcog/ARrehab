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

class Player : Entity, HasModel, HasCollision, HasAnchoring{
    
    var playerSubs: [Cancellable] = []
    
    var isColliding: Bool
    var collidingWith: Tile
    let defaultTile = Tile(name: "Default", x: 0.0, z: 0.0)
    
    required init(target: AnchoringComponent.Target) {
        self.isColliding = false
        collidingWith = defaultTile
        
        super.init()
                
        self.components[AnchoringComponent] = AnchoringComponent(target)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 2, height: 2, depth: 2), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false)])
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.1, height: 0.1, depth: 0.1)], mode: .trigger, filter: .sensor)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func addCollision() {
        guard let scene = self.scene else {return}
        playerSubs.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            print("Collision Started")
            guard let tile = event.entityB as? Tile else {
                return
            }
            print("On Tile: \(tile.tileName)")
            tile.model?.materials = [
                SimpleMaterial(color: .yellow, isMetallic: false)
            ]
            self.isColliding = true
            self.collidingWith = tile
            })
        playerSubs.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            print("Collision Ended")
            guard let tile = event.entityB as? Tile else {
                return
            }
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
            self.isColliding = false
            self.collidingWith = self.defaultTile
            })
        playerSubs.append(scene.subscribe(to: CollisionEvents.Updated.self, on: self) { event in
            guard let tile = event.entityB as? Tile else {
                return
            }
            self.isColliding = true
            self.collidingWith = tile
        })
    }
    
}
