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


class StartViewController: UIViewController {
    
    /// The app's root view.
    @IBOutlet var arView: ARView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBAction func hard(_ sender: Any) {
        let hardAdventure = try! Hard.loadScene()
        arView.scene.addAnchor(hardAdventure)
    }
    
    @IBAction func easy(_ sender: Any) {
        let easyAdventure = try! Easy.loadEasyAdventure()
        arView.scene.addAnchor(easyAdventure)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the AR session for horizontal plane tracking.
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arView.session.run(arConfiguration)
    }
    
}


class GameViewController: UIViewController {
    
    /// The app's root view.
    @IBOutlet var arView: ARView!
    
    /// A view that instructs the user's movement during session initialization.
    @IBOutlet weak var coachingOverlay: ARCoachingOverlayView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var rollDice: UIButton!
    
    /// The game controller, which manages game state.
    var gameController: GameController!
    
    /// The Player's Trigger volume
    var player: TriggerVolume!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Player's Trigger volume
        player = TriggerVolume(shape: ShapeResource.generateBox(width: 0.5, height: 2, depth: 0.5))
        
        // Initialize the game controller, which begins the game.
        gameController = GameController(player: player)
        gameController.begin()
        
        presentCoachingOverlay()
    }
    
    /// Begins the coaching process that instructs the user's movement during
    /// ARKit's session initialization.
    func presentCoachingOverlay() {
        coachingOverlay.session = arView.session
        //coachingOverlay.delegate = self as! ARCoachingOverlayViewDelegate
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = false
        self.coachingOverlay.setActive(true, animated: true)
    }
    
    // Handles what happens when the roll dice button is tapped
    @IBAction func rollDicePressed(_ sender: UIButton) {
        
        let roll1 = GameDice.rollDice()
        
        label.text = "You rolled a: \(roll1). "
        
        rollDice.setImage(UIImage(named: "Dice\(roll1)"), for: .normal)
    }
    
}
