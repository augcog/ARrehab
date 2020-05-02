//
//  TraceGame.swift
//  ARrehab
//
//  Created by Eric Wang on 3/15/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//
//  TraceGame class for tracing figures with a "laser" by moving the iPad.
//  This targets upper body movement.
//  TraceGame class is an Entity that holds a pointCloud of TracePoints which
//  individually light up or change color upon collision with the laser.
//  Laser class provides collision events for TracePoints along with providing
//  visual feedback for where the user is pointing to with the iPad.

import Foundation
import RealityKit
import Combine
import MultiProgressView
import UIKit

/**
Trace Game Entity holds a pointCloud of TracePoints which the uesr needs to trace over with the Laser.
 */
class TraceGame : Minigame {
    
    /// list of TracePoints that make up this target.
    var pointCloud : [TracePoint] = []
    /// Collision group for the TracePoints
    var pointCollisionGroup : CollisionGroup
    /// Collision group for the laser.
    var laserCollisionGroup : CollisionGroup
    // The laser that interacts with the TracePoints.
    var laser : Laser
    /// Total number of points in the pointCloud
    var total : Int
    /// Total number of points still active
    var active : Int
    
    /// Models of the targets.
    var models : [String : ModelComponent] = [:]
    /// Colors to use in the UI progress bar and upon laser contact.
    var colorMap : [String : UIColor] = [:]
    /// Positions to generate each model target. {name : [Min, Max]}
    var positionMap : [String : [SIMD3<Float>]] = [:]

    
    required init() {
        self.pointCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max)) //TODO: Find some way to not rely on generating a random integer
        self.laserCollisionGroup = CollisionGroup(rawValue: self.pointCollisionGroup.rawValue+1)
        self.laser = Laser()
        self.laser.collision?.filter = CollisionFilter(group: self.laserCollisionGroup, mask: self.pointCollisionGroup)
        self.total = 10
        self.active = self.total
        
        super.init()
        
        do {
            models.updateValue((try Entity.loadModel(named: "Fox").model!), forKey: "Fox")
            colorMap.updateValue(UIColor.red, forKey:"Fox")
            positionMap.updateValue([SIMD3<Float>(-3, -1.5, 0), SIMD3<Float>(0, -0.5, 3)], forKey: "Fox")
            models.updateValue((try Entity.loadModel(named: "Bear").model!), forKey: "Bear")
            colorMap.updateValue(UIColor.blue, forKey:"Bear")
            positionMap.updateValue([SIMD3<Float>(0, -0.5, 3), SIMD3<Float>(3, 0.5, 5)], forKey: "Bear")
        } catch {
            models.updateValue((ModelComponent(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .purple, isMetallic: false)])), forKey: "Default")
            colorMap.updateValue(UIColor.gray, forKey:"Default")
            positionMap.updateValue([SIMD3<Float>(-3, -1.5, 0), SIMD3<Float>(3, 0.5, 5)], forKey: "Default")
        }
        
        for _ in 1 ... total {
            let (name, model) = models.randomElement()!
            let posMin = positionMap[name]![0]
            let posMax = positionMap[name]![1]
            let point : TracePoint = TracePoint(model: model, translation: SIMD3<Float>(Float.random(in: posMin[0] ... posMax[0]), Float.random(in: posMin[1] ... posMax[1]), Float.random(in:posMin[2] ... posMax[2])), type: name, collisionColor: colorMap[name]!)
            point.collision?.filter = CollisionFilter(group: self.pointCollisionGroup, mask: self.laserCollisionGroup)
            
            pointCloud.append(point)
            self.addChild(point)
        }
    }
    
    /// Updates traceGame with the new TraceGame.
    /// Attaches the new TraceGame 1 m away from the camera and 1.5 meters high in the air.
    /// Attaches the Laser to the cameraEntity.
    /// - Parameters:
    ///   - ground: entity to anchor the trace targets to. Typically a fixed plane anchor.
    ///   - player: entity to anchor the laser to. Typically the camera.
    override func attach(ground: Entity, player: Entity) {
        // All coordinates are relative to the ground anchor which will be the parent of the TraceGame.
        // Player position
        var playerPosition = player.position(relativeTo: ground)
        // Our target position (also where the TraceGame will be located).
        // Currently its set to be 1m in front of the camera
        var targetPosition = player.convert(position: SIMD3<Float>(0,0,-1), to: ground)
        // Get the position transform from the player to the target
        targetPosition = targetPosition - playerPosition
        // Extract the x and z values of the transform (Find the projection to the ground plane)
        targetPosition.y = 0
        // Fix the player position at a height of 1.5 m.
        playerPosition.y = 1.5
        // Get a unit vector of our target projection then add it to our player position
        targetPosition = simd_normalize(targetPosition) + playerPosition
        // This should result in a position denoted by a 1m vector extending out from the player in the XZ direction the player is facing. This position is fixed at a height of 1.5 m.
//      print(targetPosition)
        // Set the target at thee desired position and orient it towards the player.
        self.look(at: playerPosition, from: targetPosition, relativeTo: ground)
        ground.addChild(self)
        player.addChild(self.getLaser())
    }
    
    override func run() -> Bool {
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
    
    override func endGame() -> Float {
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
        progress = Float(total - active) / Float(total)
        score = progress * 100.0
        return score
    }
}

/**
 TracePoint Entity is an individual point the laser interacts with.
 By default, it changes color upon contact to red and to clear after contact ends.
 */
class TracePoint : Entity, HasModel, HasCollision {
    var active = true
    var type : String
    var collisionColor : UIColor
    
    required convenience init() {
        self.init(model: ModelComponent(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .cyan, isMetallic: false)]))
    }
    
    init(model : ModelComponent) {
        self.type = "Default"
        self.collisionColor = .green
        super.init()
        let radius : Float = 0.5
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: model.mesh.bounds.boundingRadius / sqrtf(3)).offsetBy(translation: model.mesh.bounds.center)], mode: .trigger, filter: .default)
        self.components[ModelComponent] = model
        let scaleFactor = radius/model.mesh.bounds.boundingRadius
        self.transform.scale = SIMD3<Float>(scaleFactor, scaleFactor, scaleFactor)
        self.transform.rotation = simd_quatf(angle: Float.random(in: 5.0 * .pi/6 ... 7.0 * .pi/6), axis: SIMD3<Float>(0,1,0))
    }
    
    required convenience init(translation: SIMD3<Float>) {
        self.init()
        self.transform.translation = translation
    }
    
    convenience init(model : ModelComponent, translation: SIMD3<Float>, type: String, collisionColor: UIColor) {
        self.init(model: model)
        self.type = type
        self.collisionColor = collisionColor
        self.transform.translation = translation
    }
    
    func onCollisionBegan() {
        if (active) {
            self.model?.materials = [SimpleMaterial(color: self.collisionColor, isMetallic: false)]
        }
    }
    
    func onCollisionEnded() {
        self.model?.materials = [
            SimpleMaterial(color: .clear, isMetallic: false)
        ]
        if (active) {
            active = false
            (self.parent as! TraceGame).score()
        }
    }
}

/**
 Laser class is what the user controls typically via rotation of the camera. It interacts with TracePoints within a certain distance.
 */
class Laser : Entity, HasCollision, HasModel { // TODO: consider using a PointLight,   HasDirectionalLight, HasSpotLight
    var subscriptions: [Cancellable] = []
    
    required init() {
        super.init()
        let length : Float = 10
        // Create a 10 m long "laser"
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateCapsule(height: length, radius: 0.01)], mode: .trigger, filter: .default)
        // Create a visual representation of this 10 m long laser.
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(size: SIMD3<Float> (0.02,length,0.02)), materials: [SimpleMaterial(color: .green, isMetallic: false)])
        
        // figure out how this rotation is happening
        let angle : Float = 3.0 * .pi / 8
        self.transform.rotation = simd_quatf(angle: 2.0 * .pi - angle, axis: SIMD3<Float>(1, 0,0))
        self.transform.translation = SIMD3<Float>(0,-0.2 + length/2*Float(cos(angle)), -length/2 * Float(sin(angle)))
    }
    
    /**
        Adds Collision Capabilities. Run this function after adding the Laser to the scene.
     
        No Effect if run before Laser is part of a scene.
     */
    func addCollision() {
        guard let scene = self.scene else {return}
        subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            guard let point = event.entityB as? TracePoint else {
//                print("Bad Collision Event with", event.entityB)
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
