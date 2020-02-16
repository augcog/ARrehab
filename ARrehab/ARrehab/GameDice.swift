//
//  GameDice.swift
//  ARrehab
//
//  Created by Eric Wang on 2/16/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation

class GameDice {
    init() {
        
    }
    
    static func rollDice() -> Int {
        return Int.random(in: 1 ... 6)
    }
}
