//
//  Pseudo Code.swift
//  ARrehab
//
//  Created by Alan Zhang on 2020/6/8.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation

class Minigame : Entity {
    @Published var score
    @Published var progress
    var ViewController : MinigameViewController
    func generateViewController() -> MinigameViewController
        // generate a ViewController for the Minigame
    required init(){
        self.ViewController = generateViewController()
    }
}

class MinigameViewController : UIViewController {
