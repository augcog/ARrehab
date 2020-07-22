//
//  ExpressionViewController.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 7/21/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import RealityKit

class ExpressionViewController: MinigameViewController {
        
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var expressionLabel: UILabel!
    @IBOutlet weak var timeLeftProgressBar: UIProgressView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = ARFaceTrackingConfiguration()
        config.worldAlignment = .gravity
    }
    
    
}

extension ExpressionViewController: ARSessionDelegate {
    
}
