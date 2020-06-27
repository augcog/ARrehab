//
//  BasketGame.swift
//  ARrehab
//
//  Created by Eric Wang on 6/24/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import Combine

class BasketGame : Minigame {
    var throwers : [Thrower] = []
    var targetEntity : TriggerVolume
    var subscriptions: [Cancellable] = []
    
    required init() {
        // TODO fix box sizes for better playing.
        targetEntity = TriggerVolume(shape: ShapeResource.generateBox(width: 0.5, height: 0.2, depth: 0.5))
        super.init()
    }
    
    override func attach(ground: Entity, player: Entity) {
        player.addChild(self.targetEntity)
        self.throwers.append(Thrower(from: SIMD3<Float>(1, 1, 0), targetEntity: targetEntity))
        for thrower in throwers {
            self.addChild(thrower)
        }
        ground.addChild(self)
    }
    
    override func run() -> Bool {
        for thrower in throwers {
            thrower.createTimer(interval: 1)
        }
        return true
    }
    
    override func endGame() -> Float {
        self.targetEntity.removeFromParent()
        for thrower in throwers {
            thrower.removeFromParent()
        }
        throwers.removeAll()
        return score
    }
    
    func addCollision()
    {
        guard let scene = self.scene else {return}
        self.subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: targetEntity) { event in
            print("Basket Game Collision began")
            guard let ball = event.entityB as? Ball else {
                return
            }
            self.score += 1
            ball.removeFromParent()
            print("Basket Game Collision Began Ended")
        })
        // TODO maybe add another TriggerVolume or a ball lifetime timer to detect balls that aren't caught as a penalty?
    }
}

class Ball : Entity, HasModel, HasPhysics, HasCollision {
    required init() {
        super.init()
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2)])
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateSphere(radius: 0.2), materials: [SimpleMaterial(color: .red, isMetallic: false)])
        self.components[PhysicsBodyComponent] = PhysicsBodyComponent(massProperties: PhysicsMassProperties(mass: 1.0), material: .default, mode: .dynamic)
    }
}

class Thrower : Entity, HasModel {
    var targetEntity : Entity? = nil
    
    convenience init(from: SIMD3<Float>, targetEntity: Entity) {
        self.init()
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 1, height: 2, depth: 1), materials: [SimpleMaterial.init(color:.blue, isMetallic: true)])
        self.targetEntity = targetEntity;
        // TODO, make the Thrower track the player on every frame.
        // Probably best done relative to world frame, look at player location, from thrower location.
        self.look(at: SIMD3<Float>(0,0,0), from: position, relativeTo: targetEntity)
    }
    
    /**
     Launches a ball at the targetEntity.
     */
    func launch() {
        guard targetEntity != nil else {
            return
        }
        launch(impulse: calculateImpulse(target: targetEntity!.position(relativeTo: self)))
    }
    
    /**
     Launches a ball with the given impulse.
     */
    func launch(impulse : SIMD3<Float>) {
        let ball = Ball()
        self.addChild(ball)
        // TODO consider a ball with a mass != 1kg.
        ball.applyLinearImpulse(impulse, relativeTo: nil)
    }
    
    /**
     Calculate the impulse necessary for a 1kg ball to fly
     */
    func calculateImpulse(target: SIMD3<Float>) -> SIMD3<Float> {
        // TODO actually calculate the impulse
        return target
    }
    
    /**
     Creates a timer with an interval at which to throw balls.
     */
    func createTimer(interval: Float) {
        fatalError()
        // create timer with interval
        // run launch() on repeat
    }
}
