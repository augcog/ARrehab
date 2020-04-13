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
    
    func addTileButtonToView() {
        let tileButton = UIButton(type: .system)
        
        tileButton.frame = CGRect(x: 150, y: 150, width: 200, height: 100)
        tileButton.tintColor = .white
        tileButton.backgroundColor = .gray
        tileButton.setTitle("Add / Remove Tile", for: .normal)
        
        tileButton.addTarget(self, action: #selector(tileButtonClicked), for: .touchUpInside)
        
        self.view.addSubview(tileButton)
        self.view.bringSubviewToFront(tileButton)
    }
    
    @objc func tileButtonClicked(sender: UIButton) {
        print("Tile Button Clicked")
        
        guard let tile = playerEntity.onTile else {return}
        guard self.tileGrid!.possibleTiles.contains(tile) else {return}
        
        if self.tileGrid!.selectedTiles.contains(tile) {
            print("Removing tile " + tile.name + " from selected tiles")
            self.tileGrid!.selectedTiles.removeAll(where: {$0 == tile})
            tile.isDisplayed = false
            tile.changeColor(color: SimpleMaterial.Color.clear)
        }
        else {
            self.tileGrid!.selectedTiles.append(tile)
            tile.isDisplayed = true
            tile.changeColor(color: SimpleMaterial.Color.clear)
        }
        
    }
    
}
