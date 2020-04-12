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
    
    var visualizedPlanes = [ARAnchor]()
    
    var hasMapped: Bool!
    
    let playerEntity = Player(target: .camera)
    var gameBoard: GameBoard = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        hasMapped = false
        arView.scene.addAnchor(playerEntity)
        
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            arConfig.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("This device does not support people occlusion")
        }
                
        arView.session.delegate = self
        arView.session.run(arConfig)
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        let visualizedPlanes = anchors.filter() {anc in self.visualizedPlanes.contains(anc)}
        updatePlaneVisual(anchors: visualizedPlanes)
        
        let nonVisualizedPlanes = anchors.filter() {anc in
            !self.visualizedPlanes.contains(anc)}
        visualizePlanes(anchors: nonVisualizedPlanes, floor: true)
        
    }
    
    func generateBoard(planeAnchor: ARPlaneAnchor) {
        
        guard isValidSurface(plane: planeAnchor) else {return}
        
        let xExtent = planeAnchor.extent.x
        let zExtent = planeAnchor.extent.z
        
        let xSize = Tile.tileSize.x
        let zSize = Tile.tileSize.z
        
        var currentX = xExtent/2
        var currentZ = zExtent/2
        
        var listOfTiles : [Tile] = []
        
        while abs(currentX) <= xExtent/2 {
            while abs(currentZ) <= zExtent/2 {
                let newTile = Tile(name: String(format: "Tile (%f,%f)", currentX, currentZ), x: currentX, z: currentZ)
                listOfTiles.append(newTile)
                currentZ -= zSize
            }
            currentZ = zExtent/2
            currentX -= xSize
        }
        
        self.gameBoard = GameBoard(tiles: listOfTiles, surfaceAnchor: planeAnchor)
        self.arView.scene.addAnchor(self.gameBoard.board)
        
        self.playerEntity.addCollision()
        addTileButtonToView()
    }
}

extension ViewController {
    
    //Checks if plane is valid surface, according to x and z extent minimums
    func isValidSurface(plane: ARPlaneAnchor) -> Bool {
        guard plane.alignment == .horizontal else {return false}
        let boundaryOne = plane.extent.x
        let boundaryTwo = plane.extent.z
        return min(boundaryOne, boundaryTwo) >= 1 && max(boundaryOne, boundaryTwo) >= 2
    }
    
    //Plane visualization methods, for use in development
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
}
