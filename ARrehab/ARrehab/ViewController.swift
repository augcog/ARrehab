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
    
    let colorList = [SimpleMaterial.Color.blue, SimpleMaterial.Color.yellow, SimpleMaterial.Color.green, SimpleMaterial.Color.gray, SimpleMaterial.Color.red]
    
    var hasMapped: Bool!
    var visualizedPlanes = [ARAnchor]()

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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        //visualizePlanes(anchors: anchors)
        
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
        
        let visualizedPlanes = anchors.filter() {anc in self.visualizedPlanes.contains(anc)}
        updatePlaneVisual(anchors: visualizedPlanes)
        
        let nonVisualizedPlanes = anchors.filter() {anc in
            !self.visualizedPlanes.contains(anc)}
        visualizePlanes(anchors: nonVisualizedPlanes, floor: true)
        
        //updatePlaneVisual(anchors: anchors)
        
        /*for anc in anchors {
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            
            if isValidSurface(plane: planeAnchor) {
                let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)
                generateTiles(plane: planeAnchor, anchor: planeAnchorEntity)
                hasMapped = true
            }
        }*/
        
    }
    
    func visualizePlanes(anchors: [ARAnchor]) {
        for anc in anchors {
            
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)
                        
            for point in planeAnchor.geometry.boundaryVertices {
                let pointEntity = ModelEntity.init(mesh: MeshResource.generatePlane(width: 0.01, depth: 0.01))
                pointEntity.transform = Transform(translation: point)
                planeAnchorEntity.addChild(pointEntity)
            }
            
            let planeModel = ModelEntity()
            planeModel.model = ModelComponent(mesh: MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.z), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue.withAlphaComponent(CGFloat(0.1)), isMetallic: true)])
            planeModel.transform = Transform(pitch: 0, yaw: 0, roll: 0)
            
            planeAnchorEntity.addChild(planeModel)
            
            planeAnchorEntity.name = planeAnchor.identifier.uuidString
            
            arView.scene.addAnchor(planeAnchorEntity)
            self.visualizedPlanes.append(planeAnchor)
        }
    }
    
    func visualizePlanes(anchors: [ARAnchor], floor: Bool) {
        let validAnchors = anchors.filter() {anc in
            guard let planeAnchor = anc as? ARPlaneAnchor else {return false}
            return isValidSurface(plane: planeAnchor) == floor
        }
        
        visualizePlanes(anchors: validAnchors)
    }
    
    func updatePlaneVisual(anchors: [ARAnchor]) {
        for anc in anchors {
            
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            
            guard let planeAnchorEntity = self.arView.scene.findEntity(named: planeAnchor.identifier.uuidString) else {return}
            
            var newBoundaries = [ModelEntity]()
            
            for point in planeAnchor.geometry.boundaryVertices {
                let pointEntity = ModelEntity.init(mesh: MeshResource.generatePlane(width: 0.01, depth: 0.01))
                pointEntity.transform = Transform(translation: point)
                newBoundaries.append(pointEntity)
            }
            
            planeAnchorEntity.children.replaceAll(newBoundaries)
            
            let modelEntity = ModelEntity(mesh: MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.z), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue.withAlphaComponent(CGFloat(0.1)), isMetallic: true)])
            
            planeAnchorEntity.addChild(modelEntity)
        }
    }
    
    func isValidSurface(plane: ARPlaneAnchor) -> Bool {
        guard plane.alignment == .horizontal else {return false}
        let boundaryOne = plane.extent.x
        let boundaryTwo = plane.extent.z
        return min(boundaryOne, boundaryTwo) >= 1 && max(boundaryOne, boundaryTwo) >= 2
    }
    
    func generateTiles(plane: ARPlaneAnchor, anchor: AnchorEntity) {
        var numberOfXTiles = round(plane.extent.x / 0.5)
        var numberOfZTiles = round(plane.extent.z / 0.5)
        
        var currentX = -(plane.extent.x / 2.0) + 0.25
        var currentZ = -(plane.extent.z / 2.0) + 0.25
        
        var x = 0
        while Float(x) < numberOfXTiles {
            var z = 0
            while Float(z) < numberOfZTiles {
                print(currentX)
                print(currentZ)
                let tile = Tile(name: String(format: "Tile (%d,%d)", currentX, currentZ), x: currentX, z: currentZ)
                anchor.addChild(tile)
                
                currentZ += 0.5
                z += 1
            }
            currentX += 0.5
            x += 1
        }
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
}
