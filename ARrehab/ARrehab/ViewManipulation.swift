//
//  ViewManipulation.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 4/8/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import RealityKit

/*
 Contains methods that add/remove UI elements from the view, or in some other way manipulate non-AR content displayed to the user
 */
extension ViewController {
    
    func addPbButton() {
        let pbButton = PlaceBoardButton()
        pbButton.addTarget(self, action: #selector(pbButtonClicked(sender:)), for: .touchUpInside)
        
        self.view.addSubview(pbButton)
        self.view.bringSubviewToFront(pbButton)
        
        self.activeButtons.append(pbButton)
    }
    
    /// Generates the Gameboard, transitioning away from the Tile Placement view.
    /// - Parameter sender: Button that was clicked.
    @objc func pbButtonClicked(sender: UIButton) {
        print("PB Button Clicked")
        
        guard (self.tileGrid?.currentOutline != []) else {
            print("Not a valid board position")
            return
        }
        self.boardState = .placed
        
        self.moveToGameplay()
        //self.addBackgroundModel()
        
    }
    
    func addRbButton() {
        let rbButton = RotateBoardButton()
        rbButton.addTarget(self, action: #selector(rbButtonClicked(sender:)), for: .touchUpInside)
        
        self.view.addSubview(rbButton)
        self.view.bringSubviewToFront(rbButton)
        
        self.activeButtons.append(rbButton)
    }
    
    @objc func rbButtonClicked(sender: UIButton) {
        print("Button Clicked")
        switch self.tileGrid?.rotated {
        case .north:
            self.tileGrid?.rotated = .east
            self.activeButtons[1].setTitle("East", for: .normal)
        case .east:
            self.tileGrid?.rotated = .south
            self.activeButtons[1].setTitle("South", for: .normal)
        case .south:
            self.tileGrid?.rotated = .west
            self.activeButtons[1].setTitle("West", for: .normal)
        case .west:
            self.tileGrid?.rotated = .north
            self.activeButtons[1].setTitle("North", for: .normal)
        case .none:
            return
        }
    }
    
}
