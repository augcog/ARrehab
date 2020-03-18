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

class TraceTarget : Entity {
    // list of TracePoints that make up this target.
    var pointCloud : [TracePoint] = []
    // Collision group for the TracePoints
    var pointCollisionGroup : CollisionGroup
    // Collision group for the laser.
    var laserCollisionGroup : CollisionGroup
    // The laser that interacts withi the TracePoints.
    var laser : Laser
    
    required init() {
        self.pointCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max)) //TODO: Find some way to not rely on generating a random integer
        self.laserCollisionGroup = CollisionGroup(rawValue: self.pointCollisionGroup.rawValue+1)
        self.laser = Laser()
        self.laser.collision?.filter = CollisionFilter(group: self.laserCollisionGroup, mask: self.pointCollisionGroup)
        super.init()
        for i in -5...5 {
            let point : TracePoint = TracePoint(translation: SIMD3<Float>(Float(i)*0.2,Float(i)*0.2,Float(i)*0.2))
            point.collision?.filter = CollisionFilter(group: self.pointCollisionGroup, mask: self.laserCollisionGroup)
            pointCloud.append(point)
            self.addChild(point)
        }
        self.transform.translation = SIMD3<Float>(0,0,1.0)
    }
    
    func getLaser() -> Laser {
        return laser
    }
}

class TracePoint : Entity, HasModel, HasCollision {
    required init() {
        super.init()
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2)], mode: .trigger, filter: .default)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.2), materials: [SimpleMaterial(color: .cyan, isMetallic: false)])
    }
    
    required convenience init(translation: SIMD3<Float>) {
        self.init()
        self.transform.translation = translation
    }
}

class Laser : Entity, HasCollision, HasModel { // TODO: consider using a PointLight
    var subscriptions: [Cancellable] = []
    
    required init() {
        super.init()
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateCapsule(height: 5.0, radius: 0.1).offsetBy(rotation: simd_quatf(from: SIMD3<Float>(0,1,0), to: SIMD3<Float>(0,0,-1)), translation: SIMD3<Float>(0,5,0))], mode: .trigger, filter: .default)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(size: SIMD3<Float> (0.2,5.0,0.2)), materials: [SimpleMaterial(color: .green, isMetallic: false)])
        //self.transform.rotation = simd_quatf(from: SIMD3<Float>(0,1,0), to: SIMD3<Float>(0,0,-1))
        self.transform.translation = SIMD3<Float>(-1,-1,-1)
        addCollision()
    }
    
    func addCollision() {
        guard let scene = self.scene else {return}
        subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            guard let point = event.entityB as? TracePoint else {
                return
            }
            self.onCollisionBegan(point: point)
            
        })
        subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            guard let point = event.entityB as? TracePoint else {
                return
            }
            self.onCollisionEnded(point: point)
            
        })
    }
    
    func onCollisionBegan(point: TracePoint) {
        print("Collision with Trace Points Began")
        point.model?.materials = [
            SimpleMaterial(color: .red, isMetallic: false)
        ]
    }
    
    func onCollisionEnded(point: TracePoint) {
        point.model?.materials = [
            SimpleMaterial(color: .clear, isMetallic: false)
        ]
    }
}
