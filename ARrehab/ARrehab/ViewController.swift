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
    
    var hasMapped: Bool!
    var subscriptions: [Cancellable] = []
    
    let cameraAnchor = AnchorEntity(.camera)
    let cameraCollisionBox = ModelEntity(mesh: MeshResource.generateBox(width: 0.2, height: 1, depth: 0.2), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false)], collisionShape: ShapeResource.generateBox(width: 0.2, height: 1, depth: 0.2), mass: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        
        cameraAnchor.addChild(cameraCollisionBox)
        cameraCollisionBox.transform.translation = [0, 0, -0.5]
        print(cameraCollisionBox.transform)
        arView.scene.addAnchor(cameraAnchor)
        
//        let c = arView.scene.subscribe(to: SceneEvents.Update.self) { (event) in
////          guard let cameraBox = ModelEntity? else {
////            return
////          }
//          // Translation matrix that moves the box 1m in front of the camera
//          let translate = float4x4(
//            [1,0,0,0],
//            [0,1,0,0],
//            [0,0,1,0],
//            [0,0,-1,1]
//          )
//
//          // Transformed applied right to left
//            let finalMatrix = self.arView.cameraTransform.matrix * translate
//
//            self.cameraCollisionBox.setTransformMatrix(finalMatrix, relativeTo: nil)
//
//        }
//        self.subscriptions.append(c)

        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        arView.session.delegate = self
        arView.session.run(arConfig)
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if (hasMapped) {
            //print(cameraCollisionBox.transform)
            return
        }
        let anc = anchors[0]
        let ancEntity = AnchorEntity(anchor: anc)
        for x in -1 ... 1 {
            for z in -1 ... 1 {
                ancEntity.addChild(Tile(name: String(format: "Tile (%d,%d)", x, z), x: Float(x)/2.0, z: Float(z)/2.0))
            }
        }
        let subscription = self.arView.scene.subscribe(to: CollisionEvents.Began.self, on: cameraCollisionBox) {
            event in
            print("Collision Started")
            guard let tile = event.entityB as? Tile else {
                return
            }
            self.updateCustomUI(message: ("On Tile: " + tile.name))
            tile.model?.materials = [
                SimpleMaterial(color: .red, isMetallic: false)
            ]
        }
        self.subscriptions.append(subscription)
        self.arView.scene.addAnchor(ancEntity)
        self.hasMapped = true
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
}
