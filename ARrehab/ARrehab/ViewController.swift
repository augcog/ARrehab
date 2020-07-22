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
    
    /// AR View
    @IBOutlet var arView: ARView!
    
    var visualizedPlanes : [ARPlaneAnchor] = []
    var activeButtons : [UIButton] = []
    var trackedRaycasts : [ARTrackedRaycast?] = []
    
    /// boardState could be notMapped, mapping, mapped, or placed
    var boardState : BoardState = .notMapped
    
    /// gameBoard is a collection of tileGrid (TBC)
    var tileGrid: TileGrid?
    var gameBoard: GameBoard?
    
    /// The Player Entity that is attached to the camera.
    let playerEntity = Player(target: .camera)

    /// The ground anchor entity that holds the tiles and other fixed game objects
//  var groundAncEntity: AnchorEntity!

    /// Switch that turns on and off the Minigames, cycling through them.
    @IBOutlet var minigameSwitch: UISwitch!

    /// Label to display minigame output.
    @IBOutlet var minigameLabel: UILabel!
  
    /// Minigame Controller Struct
    var minigameController: MinigameController!
    var subscribers: [Cancellable] = []
    
    /// Add the player entity and set the AR session to begin detecting the floor.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Assign the ViewController class to act as the session's delegate (extension below)
        arView.session.delegate = self
        startTracking()
        
        minigameSwitch.isHidden = true
        minigameLabel.isHidden = true
        
        self.arView.debugOptions = [.showStatistics]
        
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
            if let validPlaneAnc = checkForValid(anchors: anchors) {
                self.initiateBoardLayout(surfaceAnchor: validPlaneAnc)
            }
        }
            
        else if self.boardState == .mapped {
            if let updatedAnchor = checkForUpdate(anchors: anchors) {
                self.tileGrid?.updateBoard(updatedAnc: updatedAnchor)
            }
        }        
    }
    
    //Checks a list of anchors for one that meets the valid surface requirements described by the GameBoard's EXTENT constants
    func checkForValid(anchors: [ARAnchor]) -> ARPlaneAnchor? {
        guard self.boardState == .notMapped else {return nil}
        for anc in anchors {
            if let planeAnc = anc as? ARPlaneAnchor {
                if isValidSurface(plane: planeAnc) {
                    return planeAnc
                }
            }
        }
        return nil
    }
    
    //Checks a list of anchors for one that matches the surface anchor of the tileGrid's surfaceAnchor
    func checkForUpdate(anchors: [ARAnchor]) -> ARPlaneAnchor? {
        guard self.boardState == .mapped else {return nil}
        for anc in anchors {
            if let planeAnc = anc as? ARPlaneAnchor {
                if planeAnc == self.tileGrid?.surfaceAnchor {
                    return planeAnc
                }
            }
        }
        return nil
    }
    
    func initiateBoardLayout(surfaceAnchor: ARPlaneAnchor) {
        guard self.boardState == .notMapped else {return}
        self.boardState = .mapping
        
        self.tileGrid = TileGrid(surfaceAnchor: surfaceAnchor)
        self.arView.scene.addAnchor(self.tileGrid!.gridEntity)
        self.boardState = .mapped
        
        self.addPbButton()
        self.addRbButton()
        self.startBoardPlacement()
        
        
//        setupMinigames(ground: self.tileGrid!.gridEntity)
    }
    
    func startBoardPlacement() {
        
        self.arView.scene.addAnchor(playerEntity)
        self.playerEntity.addCollision()
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 1.0)!, repeats: true) {timer in
            
            if self.boardState == .placed {
                timer.invalidate()
            }
                
            else if (self.playerEntity.onTile != nil) {
                self.tileGrid?.updateBoardOutline(centerTile: self.playerEntity.onTile!)
            }
            
        }
    }
    
}

// MARK: Board Generation Helper functions
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
    
    
    //Transition from board placement --> game mode
    func moveToGameplay() {
        
        //Clean up the tile grid and board placement buttons
        self.arView.scene.removeAnchor(self.tileGrid!.gridEntity)
        self.activeButtons.forEach { (button) in
            button.removeFromSuperview()
        }
        
        //Instantiate a gameboard object with the current tile outline and add it to the scene
        self.gameBoard = GameBoard(tiles: self.tileGrid!.currentOutline, surfaceAnchor: self.tileGrid!.gridEntity.clone(recursive: false), center: (self.tileGrid?.centerTile!.coords)!)
        self.gameBoard?.addBoardToScene(arView: self.arView)
        
        
        //Stop ARWorldTracking, as it is unnecessary from this point onwards (unless you desire further scene understanding for a specific minigame, in which case it can be re-activated)
        let newConfig = ARWorldTrackingConfiguration()
        self.arView.session.run(newConfig)
        
        //Set up the minigames
        setupMinigames(ground: self.gameBoard!.board.clone(recursive: false))
        //setupMinigames(ground: self.gameBoard!.board)
            
    }
        
    //Here is code to load in the background model. Currently not recommended -- causes iPad to heat significantly and doesn't blend with scene well
    func addBackgroundModel() {
        
        subscribers.append(Entity.loadAsync(named: "Background").sink(receiveCompletion: { (loadCompletion) in
            // Handle Errors
            print(loadCompletion)
        }, receiveValue: { (backgroundModel) in
            // Create a background entity in which we apply our transforms depending on board placement and game settings.
            let background = Entity()
            background.addChild(backgroundModel)
            self.gameBoard!.board.addChild(background)
            //  Correction for the model to be centered. Other than centering the model, no other transform needs to be done on backgroundModel
            backgroundModel.transform.translation = SIMD3<Float>(0.0779, -0.01, 0.2977)
            background.transform.translation = (self.gameBoard?.center.translation)!
            background.transform.rotation = simd_quatf(angle: self.tileGrid?.rotated.angle ?? 0, axis: SIMD3<Float>(0, 1, 0))
            background.transform.scale = SIMD3(Tile.SCALE, Tile.SCALE, Tile.SCALE)
        }))
        
    }
    
}


// MARK: Minigame Helper Functions
extension ViewController {
    /**
     Minigame switch logic.
     Switched on: a new game is created.
     Switched off: score is displayed and game is removed.
     */
    @objc func minigameSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            // TODO: Change when done with expression game
//            self.startMinigame(game: .movement)
            self.startMinigame(game: .expression)
//            self.startExpressionGame()
        } else {
            // TODO: Change when done with expression game
//            minigameController.disableMinigame()
//            self.minigameController.ground.isEnabled = false
//            self.gameBoard?.board.isEnabled = true
            let generalConfig = ARWorldTrackingConfiguration()
            self.arView.session.run(generalConfig)
            self.gameBoard?.board.isEnabled = true
        }
    }
    
    func startExpressionGame() {
        let expressionConfig = ARFaceTrackingConfiguration()
        expressionConfig.worldAlignment = .gravity
        self.gameBoard?.board.isEnabled = false
        self.arView.session.run(expressionConfig, options: [])
    }
    
    /**
     Adds the controller as a subview programmatically.
     */
    private func addViewController(controller: UIViewController) {
        // Add the View Controller as a subview programmatically.
        addChild(controller)
        // TODO Make a better frame depending on what UI elements are going to persist such that the Minigame Controller will not confict with the Persistent UI.
        print("Added child, creating frame.")
        let frame = self.view.frame.insetBy(dx: 0, dy: 100)
        print("Setting frame")
        controller.view.frame = frame
        print("Adding as subview")
        self.view.addSubview(controller.view)
        print("Setting Moved state")
        controller.didMove(toParent: self)
    }
    
    func setupMinigames(ground: AnchorEntity) {
        arView.scene.addAnchor(ground)
        ground.isEnabled = false
        minigameController = MinigameController(ground: ground, player: self.playerEntity)
        subscribers.append(minigameController.$score.sink(receiveValue: { (score) in
            self.minigameLabel.text = String(format:"Score: %0.0f", score)
        }))
        
        //Setup the Minigame. Switch is used for debugging purposes. In the product it should be a seamless transition.
        minigameLabel.isHidden = false
        minigameSwitch.isHidden = false
        minigameSwitch.setOn(false, animated: false)
        minigameSwitch.addTarget(self, action: #selector(minigameSwitchStateChanged), for: .valueChanged)
        addCollision()
    }
}


// MARK: Switching between Board and Minigame
extension ViewController {
    func addCollision() {
        let scene = self.arView.scene
        self.subscribers.append(scene.subscribe(to: CollisionEvents.Began.self, on: self.playerEntity) { event in
            
// TODO: This line of code mirrors the line of code in the minigame switch. Unfortunately it still crashes when the minigame switch doesn't
//            self.startMinigame(gameType: .movement)

            print("Board Collision")
            guard let tile = event.entityB as? Tile else {
                return
            }
            guard let gameType = self.gameBoard?.gamesDict[tile] else {return}
            self.startMinigame(game: gameType)
            self.gameBoard?.removeGame(tile)
            print(gameType)
            print("End collision board")
        })
    }
    
    func startMinigame(game: Game) {
        self.gameBoard?.board.isEnabled = false
        self.minigameController.ground.isEnabled = true
        let controller = self.minigameController.enableMinigame(game: game)
        print("Adding Controller")
        self.addViewController(controller: controller)
        print("Turning minigame switch on")
        self.minigameSwitch.setOn(true, animated: true)
        print("Switch is On")
    }
    
}
