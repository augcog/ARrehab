//
//  File.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 5/3/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

/*
 Defines the visual attributes of the 'Rotate Board' button to be added to the view during board generation
 */
class RotateBoardButton: UIButton {
    
    //let gbImageView = <IMAGE FROM DESIGN TEAM>
    let rbFrame = CGRect(x: 150, y: 300, width: 200, height: 100)
    let rbTintColor: UIColor = .white
    let rbBackgroundColor: UIColor = .gray
    let rbText = "Rotate Board"
    
    init() {
        super.init(frame: rbFrame)
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    private func setUpButton() {
        //self.imageView = gbImageView
        self.frame = rbFrame
        self.tintColor = rbTintColor
        self.backgroundColor = rbBackgroundColor
        self.setTitle(rbText, for: .normal)
    }
    
    func removeButton() {
        self.removeFromSuperview()
    }
    
}

