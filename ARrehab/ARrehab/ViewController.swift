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
    
    /// AR View
    @IBOutlet var arView: ARView!
    /// Switch that turns on and off the Minigames, cycling through them.
    @IBOutlet var minigameSwitch: UISwitch!
    /// Label to display minigame output.
    @IBOutlet var minigameLabel: UILabel!
    /// If a ground anchor has been detected and added to the AR scene.
    var hasMapped: Bool!
    /// The Player Entity that is attached to the camera.
    let cameraEntity = Player(target: .camera)
    /// The ground anchor entity that holds the tiles and other fixed game objects
    var groundAncEntity: AnchorEntity!
    /// Minigame Controller Struct
    var minigameController: MinigameController!
    var scoreSubscriber: Cancellable!
    
    /// Add the player entity and set the AR session to begin detecting the floor.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasMapped = false
        minigameSwitch.setOn(false, animated: false)
        
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
            minigameController = MinigameController(ground: groundAncEntity, player: cameraEntity)
            scoreSubscriber = minigameController.$score.sink(receiveValue: { (score) in
                self.minigameLabel.text = String(format:"Score: %0.0f", score)
            })
            minigameSwitch.addTarget(self, action: #selector(minigameSwitchStateChanged), for: .valueChanged)
        }
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }

    /**
     Minigame switch logic.
     Switched on: a new game is created.
     Switched off: score is displayed and game is removed.
     */
    @objc func minigameSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            minigameController.enableMinigame()
        } else {
            minigameController.disableMinigame()
        }
    }
}
