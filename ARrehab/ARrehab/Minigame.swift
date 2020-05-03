//
//  Minigame.swift
//  ARrehab
//
//  Created by Eric Wang on 3/19/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//
//  Template and controller for all Minigames.

import Foundation
import RealityKit
import Combine
import UIKit

/**
 Minigames available to play
 
 Use ```Minigame.allCases.randomElement()!``` to get a random minigame.
 */
enum Game : CaseIterable {
    // List of minigames.
    case trace
    case movement
    
    /**
     Returns a new instance of the minigame.
     */
    func makeNewInstance() -> Minigame{
        switch self {
        case .trace:
            return TraceGame()
        case .movement:
            return MovementGame(num: 3)
        }
    }
}

/**
 Base class for all minigames.
 */
class Minigame : Entity {
        
    /// Score / completion status of the minigame in the range [0.0, 100.0]
    @Published var score : Float
    
    /// Progress of the minigame in the range [0.0, 100.0] to be displayed on the progres bar.
    @Published var progress : Float
    
    var viewController : MinigameViewController!
    
    /// Initializes the minigame. Adding it to the scene as appropriate.
    ///
    /// - Parameter ground: an Entity to used as a parent for items in fixed locations.
    /// - Parameter player: an Entity that represents the player. This will be used as a parent for elements that need to update with the camera.
    convenience init(ground: Entity, player: Entity) {
        self.init()
        attach(ground: ground, player: player)
    }
    
    required init() {
        self.score = 0
        self.progress = 0
        super.init()
        self.viewController = generateViewController()
    }
    
    /**
     Creates a new ViewController
     */
    func generateViewController() -> MinigameViewController {
        let storyboard = UIStoryboard.init(name: "Minigame", bundle: nil)
        print(storyboard)
        let controller = storyboard.instantiateViewController(identifier: "minigameViewController") as! MinigameViewController
        controller.attachMinigame(minigame: self)
        return controller
    }
    
    /**
     Add to the scene as appropriate
     
     Uses the player's current location to determine the inital transofrm of the minigame.
     
     - parameters:
        - ground:  an Entity to used as a parent for items in fixed locations.
        - player:  an Entity that represents the player. This will be used as a parent for elements that need to update with the camera.
     */
    func attach(ground: Entity, player: Entity) {
        fatalError("attach() has not been implemented")
    }
    
    /**
     Start running the minigame, enabling associated entities if required.
     - Returns: If game has started successfully.
     */
    func run() -> Bool {
        fatalError("run() has not been implemented")
    }
    
    /**
     Removes the minigame from the scene;
     Returns the score of the minigame in the range [0.0, 1.0].
     */
    func endGame() -> Float {
        fatalError("endGame() has not been implemented")
    }
}

/**
 Minigame ViewController base classs.
 Each minigame will implement its own view controller should it need anythiing more than a standard progress bar.
 Please note that the UIView must be of the PassThroughView Class.
 */
class MinigameViewController : UIViewController {
    /// Progress Bar
    @IBOutlet var progressView: UIProgressView!
    var subscribers: [Cancellable] = []
    var minigame : Minigame? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        guard minigame != nil else {
            return
        }
        // TODO: Fix Nil value of progressView.
        subscribers.append(minigame!.$progress.sink(receiveValue: { (progress) in
            self.progressView.progress = progress
        }))
    }
    
    func attachMinigame(minigame: Minigame) {
        self.minigame = minigame
        if self.isViewLoaded {
            // TODO cancel the previous score subscription
            subscribers.append(minigame.$progress.sink(receiveValue: { (progress) in
                self.progressView.progress = progress
            }))
        }
    }
}

/**
 Minigame Controller. Manages minigame instances and their visibility.
 */
class MinigameController {
    
    var currentMinigame : Minigame? = nil
    var ground: Entity
    var player: Entity
    
    /// The current Minigame's ViewController. Note that this returns nil once the Minigame is ended.
    var controller : MinigameViewController? {
        get {
            currentMinigame?.viewController
        }
    }
    
    /**
     the score of the current minigame in progress [0, 100]. If no game in progress,  0 or last game's score.
     */
    @Published var score: Float
    
    /**
     the progress of the current minigame [0, 1]. If no game in progress. this is an arbitrary value.
     */
    @Published var progress: Float
    var cancellable : [Cancellable]
    
    init(ground: Entity, player: Entity) {
        self.ground = ground
        self.player = player
        self.score = 0
        self.progress = 0
        self.cancellable = []
    }
    
    /**
     Sets up a new Trace Minigame if no game is currently in progress.
     */
    func enableMinigame() -> MinigameViewController {
        return enableMinigame(game: .trace)
        //enableMinigame(game: .movement)
    }
    
    /**
     Sets up a new Minigame if no game is currently in progress.
     - Parameters:
        - game: the game to set up.
     */
    func enableMinigame(game: Game) -> MinigameViewController {
        guard currentMinigame == nil else {
             print("A Minigame is already active!")
            return self.controller!
        }
        currentMinigame = game.makeNewInstance()
        cancellable.append(currentMinigame!.$score.sink{ score in
            guard self.currentMinigame != nil else {
                self.score = 0.0
                return
            }
            self.score = score
        })
        cancellable.append(currentMinigame!.$progress.sink{ progress in
            guard self.currentMinigame != nil else {
                self.progress = 0.0
                return
            }
            self.progress = progress
        })
        currentMinigame!.attach(ground: ground, player: player)
        currentMinigame!.run()
        return self.controller!
    }
    
    /**
     Removes the current game in progress, if any.
    */
    func disableMinigame() {
        guard currentMinigame != nil else {
            print("No minigame active")
            return
        }
        currentMinigame?.endGame()
        currentMinigame = nil
        cancellable.forEach { (subscription) in
            subscription.cancel()
        }
        self.cancellable = []
    }
}
