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

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    var hasMapped: Bool!
    
    let cameraAnchor = AnchorEntity(.camera)
    let cameraCollisionBox = TriggerVolume(shape: ShapeResource.generateBox(width: 0.2, height: 4, depth: 0.2))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        
        cameraAnchor.addChild(cameraCollisionBox)
        arView.scene.addAnchor(cameraAnchor)
        
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        arView.session.delegate = self
        arView.session.run(arConfig)
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if (hasMapped) { return }
        let anc = anchors[0]
        let ancEntity = AnchorEntity(anchor: anc)
        for x in -1 ... 1 {
            for z in -1 ... 1 {
                ancEntity.addChild(Tile(name: "test", x: Float(x)/2.0, z: Float(z)/2.0).entity)
            }
        }
        arView.scene.subscribe(to: CollisionEvents.Began.self, on: cameraCollisionBox) {
            event in guard let tile = event.entityB as? Tile.entity else {
                return
            }
            updateCustomUI(tile.name)
        }
        arView.scene.addAnchor(ancEntity)
        hasMapped = true
    }
    
    
    
}
