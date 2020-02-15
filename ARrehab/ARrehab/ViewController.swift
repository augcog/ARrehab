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

class ViewController: UIViewController {
    
    /// The app's root view.
    @IBOutlet var arView: ARView!
    /// A view that instructs the user's movement during session initialization.
    @IBOutlet weak var coachingOverlay: ARCoachingOverlayView!
    
    /// The game controller, which manages game state.
    var gameController: GameController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
    
}
