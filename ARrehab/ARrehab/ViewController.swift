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
    
    var visualizedPlanes : [ARPlaneAnchor] = []
    var activeButtons : [UIButton] = []
    var trackedRaycasts : [ARTrackedRaycast?] = []
    
    var boardState : BoardState = .notMapped
    
    
    var tileGrid: TileGrid?
    var gameBoard: GameBoard?
    
    let playerEntity = Player(target: .camera)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Assign the ViewController class to act as the session's delegate (extension below)
        arView.session.delegate = self
        startTracking()
        
        //Set up the player entity
        //arView.scene.addAnchor(playerEntity)
        //playerEntity.addCollision()
        
    }
    
    private func startTracking() {
        //Define AR Configuration to detect horizontal surfaces
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        
        //Check if the device supports depth-based people occlusion and activate it if so
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            arConfig.frameSemantics.insert(.personSegmentationWithDepth)
        } else {
            print("This device does not support people occlusion")
        }
        
        //Run the tracking configuration (start detecting planes)
        self.arView.session.run(arConfig)
    }
    
}

//Extension of ViewController that acts as a delegate for the AR session
//Recieves updated scene info, can initiate actions based on scene-related events (i.e. anchor detection
extension ViewController: ARSessionDelegate {
        
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        if self.boardState == .notMapped {
            for anc in anchors {
                guard let planeAnc = anc as? ARPlaneAnchor else {break}
                if self.boardState == .notMapped {
                    if isValidSurface(plane: planeAnc) {
                        self.initiateBoardLayout(surfaceAnchor: planeAnc)
                    }
                }
            }
        }
            
        else if self.boardState == .mapped {
            for anc in anchors {
                if anc == self.tileGrid?.surfaceAnchor {
                    let planeAnc = anc as! ARPlaneAnchor
                    self.tileGrid?.updateBoard(updatedAnc: planeAnc)
                }
            }
        }
        
    }
    
    func initiateBoardLayout(surfaceAnchor: ARPlaneAnchor) {
        guard self.boardState == .notMapped else {return}
        self.boardState = .mapping
        
        self.tileGrid = TileGrid(surfaceAnchor: surfaceAnchor)
        self.arView.scene.addAnchor(self.tileGrid!.gridEntity)
        self.boardState = .mapped
        
        self.addPbButton()
        self.startBoardPlacement()
    }
    
    func startBoardPlacement() {
        
        self.arView.scene.addAnchor(playerEntity)
        self.playerEntity.addCollision()
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 1.0)!, repeats: true) {timer in
            
            if self.boardState == .placed {
                timer.invalidate()
            }
                
            else if (self.playerEntity.onTile != nil) {
                self.tileGrid?.updateBoardOutline(centerTile: self.playerEntity.onTile)
            }
            
            
        }

        /*Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 1.0)!, repeats: true, block: {timer in
            
            if self.boardState == .placed {
                timer.invalidate()
            }
            
            for tile in (self.tileGrid?.possibleTiles.values)! {
                tile.model = TileGrid.gridModel
            }
            
            //Get the current camera translation and direction via its transform matrix
            let cameraTransform = self.arView.session.currentFrame!.camera.transform
            let translation = SIMD3<Float>(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
            let direction = -SIMD3<Float>(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
            
            let direction2 = self.arView.cameraTransform.rotation
                        
            //Raycast from the camera outwards
            let raycast = self.arView.scene.raycast(origin: translation, direction: direction2.act(SIMD3(0.0, 0.0, -1.0)))
            
            
            if raycast != [] {
                for result in raycast {
                    guard let tile = result.entity as? Tile else {return}
                    tile.changeColor(color: SimpleMaterial.Color.green)
                }
                
                //Get the "middle" element in the stack of raycast results and use it as the selected tile -- TODO: Figure out a better way to select which tile is being "pointed" at
                /*if let hitTile = raycast[Int(raycast.count / 2)].entity as? Tile {
                    self.tileGrid!.updateBoardOutline(centerTile: hitTile)
                }*/
                
                //self.tileGrid?.updateBoardOutline(centerTile: centerTile!)
                //centerTile?.changeColor(color: SimpleMaterial.Color.blue)
            }
            
        })*/
    }
    
}

/*
 Helper functions
 */
extension ViewController {
    
    
    //Enumerator to represent current state of the game board
    enum BoardState {
        case notMapped
        case mapping
        case mapped
        case placed
    }
    
    
    //Checks if plane is valid surface, according to x and z extent
    func isValidSurface(plane: ARPlaneAnchor) -> Bool {
        guard plane.alignment == .horizontal else {return false}
        
        let minBoundary = min(plane.extent.x, plane.extent.z)
        let maxBoundary = max(plane.extent.x, plane.extent.z)
        
        let minExtent = min(GameBoard.EXTENT1, GameBoard.EXTENT2)
        let maxExtent = max(GameBoard.EXTENT1, GameBoard.EXTENT2)
        
        return minBoundary >= minExtent && maxBoundary >= maxExtent
    }
    
    
    //Plane visualization methods, for use in development
    func visualizePlanes(anchors: [ARAnchor]) {
        
        let pointModel = ModelEntity.init(mesh: MeshResource.generateSphere(radius: 0.01))
        
        for anc in anchors {
            
            guard let planeAnchor = anc as? ARPlaneAnchor else {return}
            let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)
                        
            for point in planeAnchor.geometry.boundaryVertices {
                let pointEntity = pointModel
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
