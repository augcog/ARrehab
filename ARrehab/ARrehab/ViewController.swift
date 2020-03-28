//
//  ViewController.swift
//  ARrehab
//
//  Created by Eric Wang on 2/12/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var traceSwitch: UISwitch!
    @IBOutlet var traceLabel: UILabel!
    
    var hasMapped: Bool!

    let cameraEntity = Player(target: .camera)
    /** Current trace game / target object. */
    var traceTarget: TraceTarget?
    var groundAncEntity: AnchorEntity!
    var currentMinigame: Minigame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        traceTarget = nil
        traceSwitch.setOn(false, animated: false)
        currentMinigame = nil
        
        arView.scene.addAnchor(cameraEntity)

        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
                
        arView.session.delegate = self
        arView.session.run(arConfig)
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if (hasMapped) {
            return
        }
        var anc: ARAnchor?
        anchors.forEach {anchor in
            guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            if (planeAnchor.alignment == .horizontal) { // TODO: change to classification == .floor, Get the planeAnchor to make sure that the plane is large enough
                anc = planeAnchor
                self.hasMapped = true
            }
        }
        if (hasMapped) {
            self.groundAncEntity = AnchorEntity(anchor: anc!)
            for x in -1 ... 1 {
                for z in -1 ... 1 {
                    let tile: Tile = Tile(name: String(format: "Tile (%d,%d)", x, z), x: Float(x)/2.0, z: Float(z)/2.0)
                    groundAncEntity.addChild(tile)
                }
            }
            
            cameraEntity.addCollision()
            
            self.arView.scene.addAnchor(groundAncEntity)
            traceSwitch.addTarget(self, action: #selector(traceStateChanged), for: .valueChanged)
        }
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
    func enterMinigame(game: Game) {
        currentMinigame = game.makeNewInstance()
        currentMinigame!.attach(ground: groundAncEntity, player: cameraEntity) //TODO: replace Entity with actual desired ground anchor.
    }
    
    func endMinigame() {
        print("Score: ", currentMinigame?.endGame())
        currentMinigame = nil
    }

    /**
     Trace switch logic. When switched on, a new trace game is created.
     */
    @objc func traceStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            traceLabel.text = "Trace is On"
            enableTraceGame()
        } else {
            traceLabel.text = "Trace is Off"
            disableTraceGame()
        }
    }
    
    /**
     Sets up a Trace Game.
     Updates traceTarget with the new TraceTarget.
     Attaches the new TraceTarget 1 m up and 1 m away from the camera.
     Attaches the Laser to the cameraEntity.
     
     Requires
     targetParent: Entity - the entity to attach the target as a child to. Typically some fixed plane anchor.
     laserParent: Entity - the entity to attach the laser as a child to. Typically the camera.
     */
    func enableTraceGame(){
        guard currentMinigame == nil else {
             print("A Minigame is already active!")
             return
        }
        enterMinigame(game: .trace)
    }
    
    /**
    Removes a Trace Game.
    Updates traceTarget to nil.
    Removes traceTarget and its Laser from its parents.
    */
    func disableTraceGame(){
        guard currentMinigame is TraceTarget else {
            print("No Trace Target")
            return
        }
        print("Removing Trace Target")
        endMinigame()
    }    
}
