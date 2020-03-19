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

class ViewController: UIViewController, ARSessionDelegate/*, ARSCNViewDelegate*/ {
    
    @IBOutlet var arView: ARView!
    
    var hasMapped: Bool!
    var planeNumber: Int = 0

    let playerEntity = Player(target: .camera)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        arView.scene.addAnchor(playerEntity)
        
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            arConfig.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("This device does not support People Occlusion with Depth")
        }
                
        arView.session.delegate = self
        arView.session.run(arConfig)
        
    }
    
    /*func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let meshGeometry = ARSCNPlaneGeometry()
        meshGeometry.update(from: planeAnchor.geometry)
        
        let meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.25
        meshNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        node.addChildNode(meshNode)
        
        print("Added Node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        guard let meshGeometry = node.childNodes.first?.geometry as? ARSCNPlaneGeometry else {return}
        meshGeometry.update(from: planeAnchor.geometry)
        
        print("Updated Node")
    }*/
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        for anc in anchors {
            
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)
            
            let planeModel = ModelEntity()
            planeModel.model = ModelComponent(mesh: MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.z), materials: [SimpleMaterial(color: SimpleMaterial.Color.clear, isMetallic: true)])
            planeModel.transform = Transform(pitch: 0, yaw: 0, roll: 0)
            
            planeAnchorEntity.addChild(planeModel)
            planeAnchorEntity.name = planeAnchor.identifier.uuidString
            
            arView.scene.addAnchor(planeAnchorEntity)
            
        }
        
        /*if (hasMapped) {
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
            let ancEntity = AnchorEntity(anchor: anc!)
            for x in -1 ... 1 {
                for z in -1 ... 1 {
                    let tile: Tile = Tile(name: String(format: "Tile (%d,%d)", x, z), x: Float(x)/2.0, z: Float(z)/2.0)
                    ancEntity.addChild(tile)
                }
            }
            
            playerEntity.addCollision()
            
            self.arView.scene.addAnchor(ancEntity)
        }*/
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        for anc in anchors {
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            
            guard let planeAnchorEntity = self.arView.scene.findEntity(named: planeAnchor.identifier.uuidString) else {return}
            
            let modelComponent = planeAnchorEntity.children.first as? ModelEntity
            modelComponent?.model = ModelComponent(mesh: MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.z), materials: [SimpleMaterial(color: SimpleMaterial.Color.clear.withAlphaComponent(CGFloat(0.5)), isMetallic: true)])
        }
        
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
}
