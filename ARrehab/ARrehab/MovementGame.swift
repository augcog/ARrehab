//
//  MovementGame.swift
//  ARrehab
//
//  Created by Eric Wang on 4/5/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//
import Foundation
import RealityKit
import Combine

/**
Movement Game Entity holds a representatioin of where the user needs to go and the detection mechanism to determine if the user has completed the action.
 */
class MovementGame : Entity, Minigame {
    
    // Collision group for the TracePoints
    var targetCollisionGroup : CollisionGroup
    // Collision group for the laser.
    var playerCollisionGroup : CollisionGroup?
    
    var subscriptions: [Cancellable] = []
    
    required init() {
        self.targetCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max)) //TODO: Find some way to not rely on generating a random integer
        self.playerCollisionGroup = nil
        
        super.init()
        for i in (-total/2)...total/2 {
            let point : TracePoint = TracePoint(translation: SIMD3<Float>(Float(i)*0.1,Float(i)*0.1,0))
            point.collision?.filter = CollisionFilter(group: self.pointCollisionGroup, mask: self.laserCollisionGroup)
            if (i == 0) {
                point.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
            }
            pointCloud.append(point)
            self.addChild(point)
        }
    }
    
    /// Updates traceTarget with the new TraceTarget.
    /// Attaches the new TraceTarget 1 m away from the camera and 1.5 meters high in the air.
    /// Attaches the Laser to the cameraEntity.
    /// - Parameters:
    ///   - ground: entity to anchor the trace targets to. Typically a fixed plane anchor.
    ///   - player: entity to anchor the laser to. Typically the camera.
    func attach(ground: Entity, player: Entity) {
        playerCollisionGroup = player.components.CollisionGroup?
        
        var playerPosition = player.position(relativeTo: ground)
        var targetPosition = player.convert(position: SIMD3<Float>(0,0,-1), to: ground)
        targetPosition = targetPosition - playerPosition
        targetPosition.y = 0
        playerPosition.y = 1.5
        targetPosition = simd_normalize(targetPosition) + playerPosition
        print(targetPosition)
        self.look(at: playerPosition, from: targetPosition, relativeTo: ground)
        ground.addChild(self)
        player.addChild(self.getLaser())
    }
    
    func run() -> Bool {
        self.getLaser().addCollision()
        self.getLaser().isEnabled = true
        assert(self.getLaser().isActive == true, "Warning Laser is not active")
        for child in self.children {
            if let tracePoint = child as? TracePoint {
                tracePoint.active = true
                assert(tracePoint.isActive == true, "Warning tracePoint is not active")
            }
        }
        return true
    }
    
    func endGame() -> Float {
        self.parent?.removeChild(self)
        self.getLaser().parent?.removeChild(self.getLaser())
        return score()
    }
    
    func getLaser() -> Laser {
        return laser
    }
    
    func score() -> Float{
        active = 0
        for child in self.children {
            if let tracePoint = child as? TracePoint {
                if (tracePoint.active) {
                    active += 1
                }
            }
        }
        return Float(total - active)/Float(total)
    }
    
    
    //TODO Modify collision to collide with Movement Target
    /**
        Adds Collision Capabilities to the MovementTarget
     */
    func addCollision() {
        guard let scene = self.scene else {return}
        subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            guard let point = event.entityB as? MovementTarget else {
                return
            }
            point.onCollisionBegan()
        })
        subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            guard let point = event.entityB as? MovementTarget else {
                return
            }
            point.onCollisionEnded()
        })
    }
}

/**
 MovementTarget Entity is a entity the player interacts with. It has a visible plane that the player must cross and stay across for a few seconds.
 By default, it changes color upon contact to green and to clear after contact ends.
 */
class MovementTarget : Entity, HasModel, HasCollision {
    var active = true
    required init() {
        super.init()
        // TODO Make these boxes / planes Make them translucent
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.05)], mode: .trigger, filter: .default)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .red, isMetallic: false)])
    }
    
    required convenience init(translation: SIMD3<Float>) {
        self.init()
        self.transform.translation = translation
    }
    
    func onCollisionBegan() {
        if (active) {
            self.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
        }
    }
    
    func onCollisionEnded() {
        self.model?.materials = [
            SimpleMaterial(color: .clear, isMetallic: false)
        ]
        if (active) {
            active = false
        }
    }
}
