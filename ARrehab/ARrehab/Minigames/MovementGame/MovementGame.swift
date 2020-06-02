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
import Dispatch

/**
Movement Game Entity holds a representatioin of where the user needs to go and the detection mechanism to determine if the user has completed the action.
 */
class MovementGame : Minigame {
    
    /// Collision group for the MovementTarget
    var targetCollisionGroup : CollisionGroup
    /// Collision subscriptions
    var subscriptions: [Cancellable] = []
    /// The player. As long as it collides with the target it counts.
    let playerCollisionEntity : TriggerVolume
    /// Number of completed targets
    var completion : Int {
        get {
            //return Int(score * Float(total) / 100.0)
            return Int(score)
        }
        set(add) {
            //score = min(100.0, Float(add) * 100.0 / Float(total))
            score = Float(add)
            progress[0] = score / Float(total)
        }
    }
    /// Number of movements to complete
    var total : Int
    /// Coaching state
    @Published
    var coachingState : MovementState
    
    var timer: Timer? = nil
    
    convenience required init() {
        self.init(num: 1)
    }
    
    required init(num: Int) {
        //TODO: Find some way to not rely on generating a random integer
        self.targetCollisionGroup = CollisionGroup(rawValue: UInt32.random(in: UInt32.min...UInt32.max))
        self.total = num
        // For our purposes, we placed the player as a 2 centimeter sphere around the camera.
        // TODO see if we even need to create this entity given that our player is already such an entity?
        self.playerCollisionEntity = TriggerVolume(shape: ShapeResource.generateSphere(radius: 0.01), filter: CollisionFilter(group:Player.PLAYER_COLLISION_GROUP, mask: targetCollisionGroup))
        self.coachingState = .up
        super.init()
        self.progress = [0, 0]
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.progress[1] = (-self.playerCollisionEntity.convert(position: SIMD3<Float>(0,0,0), to: self).y)/0.4
            var stateIsDown : MovementState? = nil
            self.children.forEach { (entity) in
                guard let target = entity as? MovementTarget else {
                    return
                }
                if (stateIsDown == nil) {
                    stateIsDown = target.state
                } else if (stateIsDown != target.state) {
                    stateIsDown = .other
                }
            }
            // Coach the next step
            if (stateIsDown == .up) {
                stateIsDown = .down
            } else if stateIsDown == .down {
                stateIsDown = .up
            }
            self.coachingState = stateIsDown ?? .other
        }
        self.timer?.tolerance = 0.1

        // Create a target with a trigger time of 1 second
        let target = MovementTarget(delay: 1, reps: num, arrow: true)
        target.collision?.filter = CollisionFilter(group: self.targetCollisionGroup, mask: Player.PLAYER_COLLISION_GROUP)
        // Change the orientation to squating rather than to the left (the default target orientation).
        // This is done by rotating by 90 degrees counter clockwise about the z axis.
        target.transform.rotation = simd_quatf(angle: -.pi/2, axis: SIMD3<Float>(0,0,1))
        // Move the squat target down by 0.2 m.
        target.transform.translation = SIMD3<Float>(0,-0.2,0)
        self.addChild(target)

        // Create a target with a trigger time of 1 second
        let hardTarget = MovementTarget(delay: 1, reps: num, arrow: false)
        hardTarget.collision?.filter = CollisionFilter(group: self.targetCollisionGroup, mask: Player.PLAYER_COLLISION_GROUP)
        // Change the orientation to squating rather than to the left
        hardTarget.transform.rotation = simd_quatf(angle: -.pi/2, axis: SIMD3<Float>(0,0,1))
        // Move the squat target down by 0.4 m.
        hardTarget.transform.translation = SIMD3<Float>(0,-0.4,0)
        self.addChild(hardTarget)
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
        self.look(at: lookDirection, from: fromDirection, relativeTo: ground)
        print(self.transform.translation)
        
        player.addChild(self.getPlayerCollisionEntity())
    }
    
    override func run() -> Bool {
        self.getPlayerCollisionEntity().isEnabled = true
        assert(self.getPlayerCollisionEntity().isActive == true, "Warning PlayerCollisionEntity is not active")
        for child in self.children {
            if let entity = child as? MovementTarget {
                entity.active = true
                assert(entity.isActive == true, "Warning MovementTarget is not active")
            }
        }
        self.coachingState = .down
        print("Adding Collision")
        self.addCollision()
        print("Collision Added")
        return true
    }
    
    override func endGame() -> Float {
        self.parent?.removeChild(self)
        self.getPlayerCollisionEntity().parent?.removeChild(self.getPlayerCollisionEntity())
        subscriptions.forEach { (subscription) in
            subscription.cancel()
        }
        subscriptions = []
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
        self.subscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: getPlayerCollisionEntity()) { event in
            print("Movement Game Collision began")
            guard let target = event.entityB as? MovementTarget else {
                return
            }
            target.onCollisionBegan()
            print("Movement Game Collision Began Ended")
        })
        // TODO this runs into a EXC_BAD_ACCESS Error
        
//        self.subscriptions.append(scene.subscribe(to: CollisionEvents.Updated.self, on: playerCollisionEntity) { event in
//            print("Movement Game Collision Updated")
//            guard let target = event.entityB as? MovementTarget else {
//                return
//            }
//            target.onCollisionUpdated()
//            print("Movement Game Collision Update Ended")
//        })
        
        self.subscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: getPlayerCollisionEntity()) { event in
            print("Movement Game Collision Ended Start")
            guard let target = event.entityB as? MovementTarget else {
                return
            }
            target.onCollisionEnded()
            print("Movement Game Collision Ended Finish")
        })
        
        print(self.subscriptions)
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
    /// Number of reps to do.
    var reps: Int
    
    var state: MovementState
    
    /** Create a movement target that is completed upon delay seconds of contact.
     Creates a large target to the left of the user, asking them to take a step to the left.
     - Parameters:
     - delay: the number of seconds it takes to complete the target
     */
    required init(delay: Double = 0, reps: Int, arrow: Bool) {
        self.state = .up
        self.delay = delay
        self.reps = reps
        super.init()
        // Create the collision box of this target and shift the box to the left by half the width such that (0,0,0) lies on the edge of the box.
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 1, height: 1, depth: 2).offsetBy(translation: SIMD3<Float>(0.5,0,0))], mode: .trigger, filter: .default)

        self.setMaterials(materials: [uncompleteMaterial])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    /// If the target is still active, set the material to in progress and start the timer.
    func onCollisionBegan() {
        self.state = .down
        if (active) {
            setMaterials(materials: [inProgressMaterial])
            self.end = DispatchTime.now() + self.delay
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay, execute: {
                print("Running Async Dispatch Callback")
                self.onCollisionUpdated()
                print("Completed Async Dispatch Callback")
            })
        }
    }
    
    /// Check if the time has exhausted and update as appropriate
    func onCollisionUpdated() {
        print("Running Collision Updated")
        if (self.active) {
            print("Target still active")
            if (self.end < DispatchTime.now()) {
                print("Time elapsed")
                self.active = false
                print("Target deactivated. Changing materials")
                setMaterials(materials: [completeMaterial])
                print("Testing parent")
                guard let game = self.parent as? MovementGame else {
                    return
                }
                print("Changing completion")
                game.completion += 1
                print("Chaning reps")
                reps -= 1
            }
        }
        print("Collision Updated Complete")
    }
    
    /// Set the appropriate material and reset the timer if needed.
    func onCollisionEnded() {
        self.state = .up
        if (!active && reps <= 0) {
            setMaterials(materials: [completeMaterial])
        } else {
            reset()
        }
    }
    
    /// Resets the target: materials, timer, etc.
    func reset() {
        print("Resetting")
        self.active = true
        setMaterials(materials: [uncompleteMaterial])
        self.end = DispatchTime.distantFuture
        print("Resetted")
    }
    
    /**
     Sets the materials of all children entities with a model component to be materials.
     - Parameters:
        - materials: the materials to give to all children entities
     */
    func setMaterials(materials:[Material]) {
        print("Setting Materials")
        for child in self.children {
            guard let modelEntity = child as? HasModel else {
                continue
            }
            modelEntity.model?.materials = materials
        }
        print("materials set")
    }
}
