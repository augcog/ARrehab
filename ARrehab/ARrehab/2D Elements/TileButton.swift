//
//  TileButton.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

/*
 Defines the visual attributes of the 'Select Tile' button to be added to the scene during board generation
 
 ***NOT IN USE (To be used along with manual board creation)
 */
class TileButton: UIButton {
    
    //let tbImageView = <IMAGE FROM DESIGN TEAM>
    let tbFrame = CGRect(x: 150, y: 150, width: 200, height: 100)
    let tbTintColor: UIColor = .white
    let tbBackgroundColor: UIColor = .gray
    let tbText = "Add / Remove Tile"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    init() {
        super.init(frame: tbFrame)
        setUpButton()
    }
    
    private func setUpButton() {
        //self.imageView = tbImageView
        self.frame = tbFrame
        self.tintColor = tbTintColor
        self.backgroundColor = tbBackgroundColor
        self.setTitle(tbText, for: .normal)
    }
    
}
