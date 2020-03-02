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
    let gameAvatarEntity = GameAvatar()
    let playerAvatarEntity: PlayerAvatar
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.playerAvatarEntity = PlayerAvatar(gameAvatar: gameAvatarEntity)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        self.playerAvatarEntity = PlayerAvatar(gameAvatar: gameAvatarEntity)
        super.init(coder: coder)
    }
    
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
                    let tile: Tile = Tile(name: String(format: "Tile (%d,%d)", x, z), x: Float(x)/2.0, z: Float(z)/2.0)
                    ancEntity.addChild(tile)
                    if x == 0 && z == 0 {
                        tile.addChild(gameAvatarEntity)
                        gameAvatarEntity.transform.translation = SIMD3<Float>(0,0.5,0)
                    }
                }
            }
            
            cameraEntity.addCollision()
            playerAvatarEntity.addCollision()
            
            self.arView.scene.addAnchor(ancEntity)
        }
    }
    
    func updateCustomUI(message: String) {
        print(message)
    }
    
}
