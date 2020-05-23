//
//  MovementState.swift
//  ARrehab
//
//  Created by Eric Wang on 5/4/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

enum MovementState {
    case down, up, other
    
    var description : String {
        switch self {
        case .down:
            return "Down"
        case .up:
            return "Up"
        case .other:
            return "Other"
        }
    }
    
    var image : UIImage? {
        switch self {
        case .down:
            return UIImage(named: "down")
        case .up:
            return UIImage(named: "up")
        case .other:
            return nil
        }
    }
}
