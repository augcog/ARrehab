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

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    var visualizedPlanes = [ARAnchor]()
    var counter = 0
    
    var boardState : BoardState = .notMapped
    
    var tileGrid: TileGrid?
    var gameBoard: GameBoard?
    
    let playerEntity = Player(target: .camera)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Define AR Configuration to detect horizontal surfaces
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        //Check if the device supports depth-based people occlusion and activate it if so
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            arConfig.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("This device does not support people occlusion")
        }
        
        //Assign the ViewController class to act as the session's delegate (extension below)
        arView.session.delegate = self
        arView.session.run(arConfig)
        
        //Set up the player entity
        arView.scene.addAnchor(playerEntity)
        playerEntity.addCollision()
        
    }
    
}

//Extension of ViewController that acts as a delegate for the AR session
//Recieves updated scene info, can initiate actions based on session-activated events
extension ViewController: ARSessionDelegate {
        
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anc in anchors {
            guard let planeAnc = anc as? ARPlaneAnchor else {return}
            if self.boardState == .notMapped {
                guard isValidSurface(plane: planeAnc) else {return}
                self.initiateBoardLayout(surfaceAnchor: planeAnc)
            }
        }
    }
    
    func initiateBoardLayout(surfaceAnchor: ARPlaneAnchor) {
        guard self.boardState == .notMapped else {return}
        self.boardState = .mapping
        
        self.tileGrid = TileGrid(surfaceAnchor: surfaceAnchor)
        self.arView.scene.addAnchor(self.tileGrid!.gridEntity)
        self.boardState = .mapped
        
        //let gbButton = self.addGbButton()
    }
}

/*
 Helper functions
 */
extension ViewController {
    
    //Checks if plane is valid surface, according to x and z extent
    func isValidSurface(plane: ARPlaneAnchor) -> Bool {
        guard plane.alignment == .horizontal else {return false}
        
        let minBoundary = min(plane.extent.x, plane.extent.z)
        let maxBoundary = max(plane.extent.x, plane.extent.z)
        
        let minExtent = min(GameBoard.EXTENT1, GameBoard.EXTENT2)
        let maxExtent = max(GameBoard.EXTENT1, GameBoard.EXTENT2)
        
        return minBoundary >= minExtent && maxBoundary >= maxExtent
    }
    
    //Enumerator to represent current state of the game board
    enum BoardState {
        case notMapped
        case mapping
        case mapped
        case placed
    }
    
    //Plane visualization methods, for use in development
    func visualizePlanes(anchors: [ARAnchor]) {
        for anc in anchors {
            
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)
                        
            for point in planeAnchor.geometry.boundaryVertices {
                let pointEntity = ModelEntity.init(mesh: MeshResource.generateSphere(radius: 0.01))
                pointEntity.transform.translation = point
                planeAnchorEntity.addChild(pointEntity)
            }
            
            let planeModel = ModelEntity()
            planeModel.model = ModelComponent(mesh: MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.z), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue.withAlphaComponent(CGFloat(0.1)), isMetallic: true)])
            planeModel.transform.translation = planeAnchor.center
            planeAnchorEntity.addChild(planeModel)
            
            let center = ModelEntity(mesh: MeshResource.generateBox(width: 0.1, height: 1, depth: 0.1), materials: [SimpleMaterial.init()])
            center.transform.translation = planeAnchor.center
            planeAnchorEntity.addChild(center)
            
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
                pointEntity.transform.translation = point
                newBoundaries.append(pointEntity)
            }
            
            planeAnchorEntity.children.replaceAll(newBoundaries)
            
            let modelEntity = ModelEntity(mesh: MeshResource.generatePlane(width: planeAnchor.extent.x, depth: planeAnchor.extent.z), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue.withAlphaComponent(CGFloat(0.1)), isMetallic: true)])
            modelEntity.transform.translation = planeAnchor.center
            
            planeAnchorEntity.addChild(modelEntity)
        }
    }
}
