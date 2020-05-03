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
    
    @objc func pbButtonClicked(sender: UIButton) {
        print("Button Clicked")
        self.boardState = .placed
        self.gameBoard = GameBoard(tiles: self.tileGrid!.currentOutline, surfaceAnchor: self.tileGrid!.surfaceAnchor)
        self.gameBoard?.addBoardToScene(arView: self.arView)
    }
    
}
