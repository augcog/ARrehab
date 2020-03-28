//
//  TraceTarget.swift
//  ARrehab
//
//  Created by Eric Wang on 3/15/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//
//  TraceTarget class for tracing figures with a "laser" by moving the iPad.
//  This targets upper body movement.
//  TraceTarget class is an Entity that holds a pointCloud of TracePoints which
//  individually light up or change color upon collision with the laser.
//  Laser class provides collision events for TracePoints along with providing
//  visual feedback for where the user is pointing to with the iPad.

import Foundation
import RealityKit
import Combine

/**
Trace Target Entity holds a pointCloud of TracePoints which the uesr needs to trace over with the Laser.
 */
class TraceTarget : Entity, Minigame {
    
    // list of TracePoints that make up this target.
    var pointCloud : [TracePoint] = []
    // Collision group for the TracePoints
    var pointCollisionGroup : CollisionGroup
    // Collision group for the laser.
    var laserCollisionGroup : CollisionGroup
    // The laser that interacts withi the TracePoints.
    var laser : Laser
    
    var total : Int
    var active : Int
    
    required init() {
        self.pointCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max)) //TODO: Find some way to not rely on generating a random integer
        self.laserCollisionGroup = CollisionGroup(rawValue: self.pointCollisionGroup.rawValue+1)
        self.laser = Laser()
        self.laser.collision?.filter = CollisionFilter(group: self.laserCollisionGroup, mask: self.pointCollisionGroup)
        self.total = 10
        self.active = self.total
        super.init()
        for i in (-(total+1)/2)...total/2 {
            let point : TracePoint = TracePoint(translation: SIMD3<Float>(Float(i)*0.1,Float(i)*0.1,0))
            point.collision?.filter = CollisionFilter(group: self.pointCollisionGroup, mask: self.laserCollisionGroup)
            pointCloud.append(point)
            self.addChild(point)
        }
    }
    
    func attach(ground: Entity, player: Entity) {
        var transform = Transform()
        transform.translation = SIMD3<Float>(0,1,-1)
        self.setTransformMatrix(transform.matrix, relativeTo: player) // what exactly does this do? what if targetParent is not (0,0,0) in world coordinates.
        ground.addChild(self) //TODO: Transform this entity relative to camera such that its in front of the camera.
        player.addChild(self.getLaser())
        self.getLaser().addCollision()
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
}

/**
 TracePoint Entity is an individual point the laser interacts with.
 By default, it changes color upon contact to red and to clear after contact ends.
 */
class TracePoint : Entity, HasModel, HasCollision {
    var active = true
    required init() {
        super.init()
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.05)], mode: .trigger, filter: .default)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .cyan, isMetallic: false)])
    }
    
    required convenience init(translation: SIMD3<Float>) {
        self.init()
        self.transform.translation = translation
    }
    
    func onCollisionBegan() {
        if (active) {
            self.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
        }
    }
    
    func onCollisionEnded() {
        self.model?.materials = [
            SimpleMaterial(color: .clear, isMetallic: false)
        ]
        active = false
    }
}

/**
 Laser class is what the user controls typically via rotation of the camera. It interacts with TracePoints within a certain distance.
 */
class Laser : Entity, HasCollision, HasModel { // TODO: consider using a PointLight
    var subscriptions: [Cancellable] = []
    
    required init() {
        super.init()
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateCapsule(height: 2.0, radius: 0.01)], mode: .trigger, filter: .default)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(size: SIMD3<Float> (0.02,2.0,0.02)), materials: [SimpleMaterial(color: .green, isMetallic: false)])
        self.transform = Transform(rotation: simd_quatf(from: SIMD3<Float>(0,1,0), to: SIMD3<Float>(0,0.5,-1)))
        self.transform.translation = SIMD3<Float>(0,0,-0.25)
    }
    
    /**
        Adds Collision Capabilities. Run this function after adding the Laser to the scene.
     
        No Effect if run before Laser is part of a scene.
     */
    func addCollision() {
        guard let scene = self.scene else {return}
        subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            guard let point = event.entityB as? TracePoint else {
                print("Bad Collision Event")
                return
            }
            point.onCollisionBegan()
        })
        subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            guard let point = event.entityB as? TracePoint else {
                return
            }
            point.onCollisionEnded()
        })
    }
}
