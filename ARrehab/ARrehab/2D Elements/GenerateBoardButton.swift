//
//  GenerateBoardButton.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

/*
 Defines the visual attributes of the 'Generate Board' button to be added to the view during board generation
 */
class GenerateBoardButton: UIButton {
    
    //let gbImageView = <IMAGE FROM DESIGN TEAM>
    let gbFrame = CGRect(x: 150, y: 150, width: 200, height: 100)
    let gbTintColor: UIColor = .white
    let gbBackgroundColor: UIColor = .gray
    let gbText = "Place Board"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    init() {
        super.init(frame: gbFrame)
        setUpButton()
    }
    
    private func setUpButton() {
        //self.imageView = gbImageView
        self.frame = gbFrame
        self.tintColor = gbTintColor
        self.backgroundColor = gbBackgroundColor
        self.setTitle(gbText, for: .normal)
    }
    
}
