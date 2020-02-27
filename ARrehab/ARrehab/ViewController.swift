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

    let cameraEntity = Player(target: .camera)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        
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
            let ancEntity = AnchorEntity(anchor: anc!)
            for x in -1 ... 1 {
                for z in -1 ... 1 {
                    ancEntity.addChild(Tile(name: String(format: "Tile (%d,%d)", x, z), x: Float(x)/2.0, z: Float(z)/2.0))
                }
            }
            
            cameraEntity.addCollision()
            
            self.arView.scene.addAnchor(ancEntity)
            
            addTileButtonToView()
        }
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
    func addTileButtonToView() {
        let tileButton = UIButton(type: .system)
        
        tileButton.frame = CGRect(x: 150, y: 150, width: 200, height: 100)
        tileButton.tintColor = .white
        tileButton.backgroundColor = .gray
        tileButton.setTitle("Add / Remove Tile", for: .normal)
        
        tileButton.addTarget(self, action: #selector(tileButtonClicked), for: .touchUpInside)
        
        self.view.addSubview(tileButton)
        self.view.bringSubviewToFront(tileButton)
    }
    
    @objc func tileButtonClicked(sender: UIButton) {
        print("Tile Button Clicked")
        let tile = cameraEntity.collidingWith
        
        if (!cameraEntity.isColliding) {
            print("You are not on a tile")
            return
        }
                
        if (tile.isDisplayed) {
            print("Deleting tile" + tile.name)
            tile.model = ModelComponent(mesh: MeshResource.generateBox(width: 0.5, height: 0.01, depth: 0.5, cornerRadius: 0.2), materials: [SimpleMaterial(color: SimpleMaterial.Color.clear, isMetallic: false)])
            tile.isDisplayed = false
            return
        }
        
        else {
            print("Adding tile" + tile.name)
            tile.model = ModelComponent(mesh: MeshResource.generateBox(width: 0.5, height: 0.01, depth: 0.5, cornerRadius: 0.2), materials: [SimpleMaterial(color: SimpleMaterial.Color.green, isMetallic: false)])
            tile.isDisplayed = true
            return
        }
    }
    
}
