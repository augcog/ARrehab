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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        traceTarget = nil
        traceSwitch.setOn(false, animated: false)
        
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
    
    /**
     Trace switch logic. When switched on, a new trace game is created.
     */
    @objc func traceStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            traceLabel.text = "Trace is On"
            enableTraceGame(targetParent: groundAncEntity, laserParent: cameraEntity)
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
    func enableTraceGame(targetParent: Entity, laserParent: Entity){
        guard traceTarget == nil else {
             print("Trace Target Already Exists!")
             return
        }
        traceTarget = TraceTarget()
        var transform = Transform()
        transform.translation = SIMD3<Float>(0,1,-1)
        traceTarget?.setTransformMatrix(transform.matrix, relativeTo: cameraEntity) // what exactly does this do? what if targetParent is not (0,0,0) in world coordinates.
        targetParent.addChild(traceTarget!) //TODO: Transform this entity relative to camera such that its in front of the camera.
        laserParent.addChild(traceTarget!.getLaser())
        traceTarget!.getLaser().addCollision()
    }
    
    /**
    Removes a Trace Game.
    Updates traceTarget to nil.
    Removes traceTarget and its Laser from its parents.
    */
    func disableTraceGame(){
        guard traceTarget != nil else {
            print("No Trace Target")
            return
        }
        print("Trace Target State: ", traceTarget!.isEnabled)
        print("Removing Trace Target")
        traceTarget?.parent?.removeChild(traceTarget!)
        cameraEntity.removeChild(traceTarget!.getLaser())
        traceTarget = nil
    }
    
}
