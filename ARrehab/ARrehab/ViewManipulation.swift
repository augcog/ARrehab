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
    
    func addGbButton() -> GenerateBoardButton {
        let gbButton = GenerateBoardButton()
        gbButton.addTarget(self, action: #selector(tileButtonClicked(sender:)), for: .touchUpInside)
        
        self.view.addSubview(gbButton)
        self.view.bringSubviewToFront(gbButton)
        
        return gbButton
    }
    
    @objc func tileButtonClicked(sender: UIButton) {
        print("Button Clicked")
    }
    
}
