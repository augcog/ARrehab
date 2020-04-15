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
import UIKit

/**
Movement Game Entity holds a representatioin of where the user needs to go and the detection mechanism to determine if the user has completed the action.
 */
class MovementGame : Entity, Minigame {
    
    // Collision group for the MovementTarget
    var targetCollisionGroup : CollisionGroup
    // Collision group for the player.
    var playerCollisionGroup : CollisionGroup
    
    var subscriptions: [Cancellable] = []
    
    let playerCollisionEntity : TriggerVolume
    
    var completion : Float
    
    required init() {
        self.targetCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max)) //TODO: Find some way to not rely on generating a random integer
        self.playerCollisionGroup = CollisionGroup(rawValue: self.targetCollisionGroup.rawValue + 1)
        self.completion = 0.0
        self.playerCollisionEntity = TriggerVolume(shape: ShapeResource.generateSphere(radius: 0.01), filter: CollisionFilter(group:playerCollisionGroup, mask: targetCollisionGroup))
        super.init()
        let target = MovementTarget(delay: 5)
        target.collision?.filter = CollisionFilter(group: self.targetCollisionGroup, mask: self.playerCollisionGroup)
        self.addChild(target)
    }
    
    /// Attaches the Movement Game to the ground anchor with the same transformation as the player.
    /// Attaches the playerCollisionObject to the player entity.
    /// - Parameters:
    ///   - ground: entity to anchor the Movement Game to. Typically a fixed plane anchor.
    ///   - player: entity to anchor the playerCollisionEntity to. Typically the camera.
    func attach(ground: Entity, player: Entity) {
        ground.addChild(self)
        var lookDirection = ground.convert(position: SIMD3<Float>(0,0,1), from: player)
        lookDirection.y = ground.convert(position: SIMD3<Float>(0,0,0), from: player).y
        var fromDirection = ground.convert(position: SIMD3<Float>(0,0,0), from: player)
        fromDirection.y = lookDirection.y
        self.look(at: lookDirection, from: fromDirection,            relativeTo: ground)
        print(self.transform.translation)
        
        player.addChild(self.getPlayerCollisionEntity())
    }
    
    func run() -> Bool {
        self.addCollision()
        self.getPlayerCollisionEntity().isEnabled = true
        assert(self.getPlayerCollisionEntity().isActive == true, "Warning PlayerCollisionEntity is not active")
        for child in self.children {
            if let entity = child as? MovementTarget {
                entity.active = true
                assert(entity.isActive == true, "Warning MovementTarget is not active")
            }
        }
        return true
    }
    
    func endGame() -> Float {
        self.parent?.removeChild(self)
        self.getPlayerCollisionEntity().parent?.removeChild(self.getPlayerCollisionEntity())
        return score()
    }
    
    func getPlayerCollisionEntity() -> Entity & HasCollision {
        return playerCollisionEntity
    }
    
    func score() -> Float{
        return completion
    }
    
    
    //TODO Modify collision to collide with Movement Target
    /**
        Adds Collision Capabilities to the MovementTarget
     */
    func addCollision() {
        guard let scene = self.scene else {return}
        subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: getPlayerCollisionEntity()) { event in
            guard let target = event.entityB as? MovementTarget else {
                return
            }
            target.onCollisionBegan()
        })
        subscriptions.append(scene.subscribe(to: CollisionEvents.Updated.self, on: getPlayerCollisionEntity()) { event in
            guard let target = event.entityB as? MovementTarget else {
                return
            }
            target.onCollisionUpdated()
        })
        subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: getPlayerCollisionEntity()) { event in
            guard let target = event.entityB as? MovementTarget else {
                return
            }
            target.onCollisionEnded()
        })
    }
}

/**
 MovementTarget Entity is a entity the player interacts with. It has a visible plane that the player must cross and stay across for a few seconds.
 By default, it changes color upon contact to yellow, to green upon completion.
 */
class MovementTarget : Entity, HasModel, HasCollision {
    var active = true
    var end = DispatchTime.distantFuture
    let delay : Double
    let completeMaterial = SimpleMaterial(color: UIColor.green.withAlphaComponent(0.7), isMetallic: false)
    let uncompleteMaterial = SimpleMaterial(color: UIColor.gray.withAlphaComponent(0.7), isMetallic: false)
    let inProgressMaterial = SimpleMaterial(color: UIColor.yellow.withAlphaComponent(1), isMetallic: false)
    let timerEntity: ModelEntity
    var timer:Timer?
    
    required init(delay: Double = 0) {
        self.delay = delay
        self.timerEntity = ModelEntity(mesh: MeshResource.generateText(String(format:"%0.2f", self.delay), font: .systemFont(ofSize: 1), alignment: .right))
        super.init()
        self.transform.translation = SIMD3<Float>(0.5,0,0.5)
        // TODO Make these boxes / planes Make them translucent
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 1, height: 1, depth: 2).offsetBy(translation: SIMD3<Float>(0.25,0,0))], mode: .trigger, filter: .default)
        let thresholdPlane = ModelEntity(mesh: MeshResource.generatePlane(width: 2, height: 1, cornerRadius: 0))
        // Rotate about the y axis such that the plane is now on the yz dimension.
        thresholdPlane.transform.rotation = simd_quatf(ix: 0, iy: 0.7071, iz: 0, r: 0.7071)
        addChild(thresholdPlane)
        let leftArrow = ModelEntity(mesh:
            MeshResource.generateText("<=", font:
                .systemFont(ofSize: 1)
                , alignment: .center)
        )
        leftArrow.transform.translation = SIMD3<Float>(0.25,-0.5,3) - self.transform.translation
        leftArrow.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,1,0))
        addChild(leftArrow)

        timerEntity.transform = Transform(matrix: leftArrow.transform.matrix)
        timerEntity.transform.translation.x += 2
        addChild(timerEntity)
        //TODO Make this box render even when inside. Most likely need to break into separate plane meshes.
        let targetBox = ModelEntity(mesh: MeshResource.generateBox(width: 1, height: 1, depth: 2))
        targetBox.transform.translation = SIMD3<Float>(0.25, 0, 0)
        addChild(targetBox)
        self.setMaterials(materials: [uncompleteMaterial])
    }
    
    required convenience init(translation: SIMD3<Float>) {
        self.init()
        self.transform.translation = translation
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func onCollisionBegan() {
        if (active) {
            setMaterials(materials: [inProgressMaterial])
            self.end = DispatchTime.now() + self.delay
            if (timer == nil) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                    if(!self.active) {
                        timer.invalidate()
                        return
                    }
                    let timeLeft = Double((self.end.uptimeNanoseconds-DispatchTime.now().uptimeNanoseconds)/1000000)/1000.0
                    self.timerEntity.model?.mesh = MeshResource.generateText(String(format:"%.2f", min(self.delay, max(0, timeLeft))), font:
                    .systemFont(ofSize: 1)
                    , alignment: .center)
                }
                self.timer!.tolerance = 0.1
            }
        }
    }
    
    func onCollisionUpdated() {
        if (active) {
            if (self.end < DispatchTime.now()) {
                setMaterials(materials: [completeMaterial])
                active = false
                self.timerEntity.model?.mesh = MeshResource.generateText("0.0", font:
                .systemFont(ofSize: 1)
                , alignment: .center)
                guard let game = self.parent as? MovementGame else {
                    return
                }
                game.completion = 1.0

            }
        }
    }
    
    func onCollisionEnded() {
        if (!active) {
            setMaterials(materials: [
                completeMaterial
            ])
        } else {
            setMaterials(materials: [uncompleteMaterial])
            self.end = DispatchTime.distantFuture
            self.timerEntity.model?.mesh = MeshResource.generateText(String(format:"$0.2f", self.delay), font:
            .systemFont(ofSize: 1)
            , alignment: .center)
        }
    }
    
    func setMaterials(materials:[Material]) {
        for child in self.children {
            guard let modelEntity = child as? ModelEntity else {
                continue
            }
            modelEntity.model?.materials = materials
        }
    }
}
