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
class MovementGame : Minigame {
    
    // Collision group for the MovementTarget
    var targetCollisionGroup : CollisionGroup
    // Collision group for the player.
    var playerCollisionGroup : CollisionGroup
    // Collision subscriptions
    var subscriptions: [Cancellable] = []
    // The player. As long as it collides with the target it counts.
    let playerCollisionEntity : TriggerVolume
    // Number of completed targets
    var completion : Int {
        get {
            //return Int(score * Float(total) / 100.0)
            return Int(score)
        }
        set(add) {
            //score = min(100.0, Float(add) * 100.0 / Float(total))
            score = Float(add)
        }
    }
    // Number of total targets
    var total : Int
    
    convenience required init() {
        self.init(num: 1)
    }
    
    required init(num: Int) {
        self.targetCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max)) //TODO: Find some way to not rely on generating a random integer
        self.playerCollisionGroup = CollisionGroup(rawValue: self.targetCollisionGroup.rawValue + 1)
        self.total = num
        // For our purposes, we placed the player as a 2 centimeter sphere around the camera.
        self.playerCollisionEntity = TriggerVolume(shape: ShapeResource.generateSphere(radius: 0.01), filter: CollisionFilter(group:playerCollisionGroup, mask: targetCollisionGroup))
        super.init()
        // Create a target with a trigger time of 1 second
        let target = MovementTarget(delay: 1, reps: num)
        target.collision?.filter = CollisionFilter(group: self.targetCollisionGroup, mask: self.playerCollisionGroup)
        // Change the orientation to squating rather than to the left
        target.transform.rotation = simd_quatf(angle: -.pi/2, axis: SIMD3<Float>(0,0,1))
        // Move the squat target down by 0.2 m.
        target.transform.translation = SIMD3<Float>(0,-0.2,0)
        self.addChild(target)
    }
    
    /// Attaches the Movement Game to the ground anchor with the same transformation as the player.
    /// Attaches the playerCollisionObject to the player entity.
    /// - Parameters:
    ///   - ground: entity to anchor the Movement Game to. Typically a fixed plane anchor.
    ///   - player: entity to anchor the playerCollisionEntity to. Typically the camera.
    override func attach(ground: Entity, player: Entity) {
        ground.addChild(self)
        var lookDirection = ground.convert(position: SIMD3<Float>(0,0,1), from: player)
        lookDirection.y = ground.convert(position: SIMD3<Float>(0,0,0), from: player).y
        var fromDirection = ground.convert(position: SIMD3<Float>(0,0,0), from: player)
        fromDirection.y = lookDirection.y
        self.look(at: lookDirection, from: fromDirection,            relativeTo: ground)
        print(self.transform.translation)
        
        player.addChild(self.getPlayerCollisionEntity())
    }
    
    override func run() -> Bool {
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
    
    override func endGame() -> Float {
        self.parent?.removeChild(self)
        self.getPlayerCollisionEntity().parent?.removeChild(self.getPlayerCollisionEntity())
        return score
    }
    
    /// Returns the player which is a collision entity
    func getPlayerCollisionEntity() -> Entity & HasCollision {
        return playerCollisionEntity
    }
    
    /**
        Adds Collision Capabilities to the Player Collision Entity
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
 In its normal orientation, it drives the player towards the left.
 By default, it begins as gray, changes color upon contact to yellow, to green upon completion.
 */
class MovementTarget : Entity, HasModel, HasCollision {
    /// Is this target still active (as opposed to completed)
    var active = true
    /// The time this target will be completed
    var end = DispatchTime.distantFuture
    /// How long does contact need to last for in seconds.
    let delay : Double
    /// Material to use when target is completed
    let completeMaterial = UnlitMaterial(color: UIColor.green.withAlphaComponent(0.7))
    /// Material to use when target is not completed and not touching
    let uncompleteMaterial = UnlitMaterial(color: UIColor.gray.withAlphaComponent(0.7))
    /// Material to use when the timer is counting down
    let inProgressMaterial = UnlitMaterial(color: UIColor.yellow.withAlphaComponent(0.5))
    /// A text model with the timer attached
    let timerEntity: ModelEntity
    /// A timer that updates the timerEntity.
    var timer:Timer?    //TODO: Consdsider switching from timer directly into the update frame.
    var reps: Int
    
    /** Create a movement target that is completed upon delay seconds of contact.
     Creates a large target to the left of the user, asking them to take a step to the left.
     - Parameters:
     - delay: the number of seconds it takes to complete the target
     */
    required init(delay: Double = 0, reps: Int) {
        self.delay = delay
        // Set the timer to delay seconds
        self.reps = reps
        self.timerEntity = ModelEntity(mesh: MeshResource.generateText(String(format:"%0.2f", self.delay), font: .systemFont(ofSize: 1), alignment: .right), materials: [uncompleteMaterial])
        super.init()
        // Create the collision box of this target and shift the box to the left by half the width such that (0,0,0) lies on the edge of the box.
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 1, height: 1, depth: 2).offsetBy(translation: SIMD3<Float>(0.5,0,0))], mode: .trigger, filter: .default)
        // TODO: Make this box render even when inside. Most likely need to break into separate plane meshes.
        // Create a visual box for the user with the same dimensions and transformations aas teh collision box.
        let targetBox = ModelEntity(mesh: MeshResource.generateBox(width: 1, height: 1, depth: 2))
        targetBox.transform.translation = SIMD3<Float>(0.5, 0, 0)
        addChild(targetBox)
        // Create a visual plane to complement the targetBox. Note that the box rendering will disappear upon contact so this is critical.
        let thresholdPlane = ModelEntity(mesh: MeshResource.generatePlane(width: 2, height: 1, cornerRadius: 0))
        // Rotate about the y axis such that the plane is now on the yz dimension.
        thresholdPlane.transform.rotation = simd_quatf(ix: 0, iy: 0.7071, iz: 0, r: 0.7071)
        addChild(thresholdPlane)
        
        // Create an indicator to move to the left
        let dirArrow = ModelEntity(mesh:
            MeshResource.generateText("<=", font:
                .systemFont(ofSize: 1)
                , alignment: .center)
        )
        dirArrow.transform.translation = SIMD3<Float>(0.25,-0.5,3) - self.transform.translation
        // Rotate the arrow by 180 degrees such that the text is facing the user.
        dirArrow.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,1,0))
        addChild(dirArrow)
        // Same thing for the timer entity
        timerEntity.transform = Transform(matrix: dirArrow.transform.matrix)
        timerEntity.transform.translation.x += 2
        // TODO Rotate it such that it faces the user and is readable.
        
        addChild(timerEntity)
        //timerEntity.transform.translation = leftArrow.convert(position: SIMD3<Float>(2,0,0), to: timerEntity.parent)

        self.setMaterials(materials: [uncompleteMaterial])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    /// If the target is still active, set the material to in progress and start the timer.
    func onCollisionBegan() {
        if (active) {
            setMaterials(materials: [inProgressMaterial])
            self.end = DispatchTime.now() + self.delay
            if (timer == nil) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                    if(!self.active) {
                        timer.invalidate()
                        self.timer = nil
                        return
                    }
                    var timeLeft : Double
                    if (DispatchTime.now() <= self.end){
                        timeLeft = Double((self.end.uptimeNanoseconds-DispatchTime.now().uptimeNanoseconds)/1000000)/1000.0
                    } else {
                        timeLeft = self.delay
                    }
                    self.timerEntity.model?.mesh = MeshResource.generateText(String(format:"%.2f", min(self.delay, max(0, timeLeft))), font:
                    .systemFont(ofSize: 1)
                    , alignment: .center)
                }
                self.timer!.tolerance = 0.1
            }
        }
    }
    
    /// Check if the time has exhausted and update as appropriate
    func onCollisionUpdated() {
        if (self.active) {
            if (self.end < DispatchTime.now()) {
                setMaterials(materials: [completeMaterial])
                self.active = false
                self.timerEntity.model?.mesh = MeshResource.generateText("0.0", font:
                .systemFont(ofSize: 1)
                , alignment: .center)
                guard let game = self.parent as? MovementGame else {
                    return
                }
                game.completion += 1
                reps -= 1
            }
        }
    }
    
    /// Set the appropriate material and reset the timer if needed.
    func onCollisionEnded() {
        if (!active && reps <= 0) {
                setMaterials(materials: [completeMaterial])
        } else {
            reset()
        }
    }
    
    /// Resets the target: materials, timer, etc.
    func reset() {
        self.active = true
        setMaterials(materials: [uncompleteMaterial])
        self.end = DispatchTime.distantFuture
        self.timerEntity.model?.mesh = MeshResource.generateText(String(format:"%0.2f", self.delay), font:
        .systemFont(ofSize: 1)
        , alignment: .center)
    }
    
    /**
     Sets the materials of all children entities with a model component to be materials.
     - Parameters:
        - materials: the materials to give to all children entities
     */
    func setMaterials(materials:[Material]) {
        for child in self.children {
            guard let modelEntity = child as? HasModel else {
                continue
            }
            modelEntity.model?.materials = materials
        }
    }
}
