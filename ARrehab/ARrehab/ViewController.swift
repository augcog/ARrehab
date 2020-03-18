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
    var traceTarget: TraceTarget?
    var groundAncEntity: AnchorEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        traceTarget = nil
        
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
            
            //cameraEntity.addCollision()
            
            self.arView.scene.addAnchor(groundAncEntity)
            traceSwitch.addTarget(self, action: #selector(traceStateChanged), for: .valueChanged)
        }
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
    @objc func traceStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            traceLabel.text = "Trace is On"
            guard traceTarget == nil else {
                print("Trace Target Already Exists!")
                return
            }
            traceTarget = TraceTarget()
            groundAncEntity.addChild(traceTarget!) //TODO: See if this entity will move.
            cameraEntity.addChild(traceTarget!.getLaser())
        } else {
            traceLabel.text = "Trace is Off"
            guard traceTarget != nil else {
                print("No Trace Target")
                return
            }
            print("Trace Target State: ", traceTarget!.isEnabled)
            print("Removing Trace Target")
            cameraEntity.removeChild(traceTarget!)
            cameraEntity.removeChild((traceTarget!.getLaser()))
        }
    }
    
}
