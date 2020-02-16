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
    
    var nextAnchor: HasAnchoring!
    
    @IBOutlet weak var label: UILabel!
    
    @IBAction func hard(_ sender: Any) {
        let hardAdventure = try! Hard.loadScene()
        nextAnchor = hardAdventure
    }
    
    @IBAction func easy(_ sender: Any) {
        let easyAdventure = try! Easy.loadEasyAdventure()
        nextAnchor = easyAdventure
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the AR session for horizontal plane tracking.
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arView.session.run(arConfiguration)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameViewController
        {
            let vc = segue.destination as? GameViewController
            vc?.anchor = nextAnchor
        }
    }
    
}


class GameViewController: UIViewController, ARCoachingOverlayViewDelegate, ARSessionDelegate {
    
    var anchor: HasAnchoring!
    
    /// The app's root view.
    @IBOutlet var arView: ARView!
    
    /// A view that instructs the user's movement during session initialization.
    @IBOutlet weak var coachingOverlay: ARCoachingOverlayView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var rollDice: UIButton!
    
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    /// The game controller, which manages game state.
    var gameController: GameController!
    
    /// The Player's Trigger volume
    var player: TriggerVolume!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        /*
        // Player's Trigger volume
        player = TriggerVolume(shape: ShapeResource.generateBox(width: 0.5, height: 2, depth: 0.5))
        
        // Initialize the game controller, which begins the game.
        gameController = GameController(player: player)
        gameController.begin()
        */
               
        arView.scene.anchors.append(anchor)
        arView.session.delegate = self
        arView.debugOptions = [ .showFeaturePoints ]
        
        // Prevent the screen from being dimmed after a while as users will likely
               // have long periods of interaction without touching the screen or buttons.UIApplication.shared.isIdleTimerDisabled = true

    }
    
    /// Begins the coaching process that instructs the user's movement during
    /// ARKit's session initialization.
    func presentCoachingOverlay() {
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
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
