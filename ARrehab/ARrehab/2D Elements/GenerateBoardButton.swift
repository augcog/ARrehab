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
class PlaceBoardButton: UIButton {
    
    //let gbImageView = <IMAGE FROM DESIGN TEAM>
    let pbFrame = CGRect(x: 150, y: 150, width: 200, height: 100)
    let pbTintColor: UIColor = .white
    let pbBackgroundColor: UIColor = .gray
    let pbText = "Place Board"
    
    init() {
        super.init(frame: pbFrame)
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpButton()
    }
    
    private func setUpButton() {
        //self.imageView = gbImageView
        self.frame = pbFrame
        self.tintColor = pbTintColor
        self.backgroundColor = pbBackgroundColor
        self.setTitle(pbText, for: .normal)
    }
    
    func removeButton() {
        self.removeFromSuperview()
    }
    
}
