//
//  TraceTargetType.swift
//  ARrehab
//
//  Created by Eric Wang on 5/3/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

/**
 Set of TraceTarget types.
 */
enum TraceTargetType {
    case bear, fox, other, puffer
    
    /**
     A list of all the possible target types.
     */
    static var allTypes: [TraceTargetType] = [.bear, .fox, .puffer, .other]
    
    /**
     The names of each type.
     */
    var description: String {
        switch self {
        case .bear:
            return "Bear"
        case .fox:
            return "Fox"
        case .other:
            return "Default"
        case .puffer:
            return "Puffer"
        }
    }
    
    /**
     The name of each target's model.
     
     Use `Entity.loadModel(named: traceTargetType.modelName)` to get a Model Entity of the target.
     */
    var modelName: String {
        return self.description
    }
    
    /**
     Color to represent the TraceTarget with.
     */
    var color: UIColor {
        switch self {
        case .bear:
            return .blue
        case .fox:
            return .green
        case .other:
            return .gray
        case .puffer:
            return .orange
        }
    }
    
    /**
     Minimum spawn positions.
     
     Positive x points to the left. z away from the user.
     */
    var minPosition: SIMD3<Float> {
        switch self {
        case .fox:
            return SIMD3<Float>(-3, 0, 0)
        case .bear:
            return SIMD3<Float>(0, 0, 1)
        case .other:
            return SIMD3<Float>(-3, 0, 0)
        case .puffer:
            return SIMD3<Float>(-3, 1, 0)
        }
    }
    
    /**
     Maximum Spawn position.
     */
    var maxPosition: SIMD3<Float> {
        switch self {
        case .fox:
            return SIMD3<Float>(0, 0.5, 3)
        case .bear:
            return SIMD3<Float>(3, 0.5, 4)
        case .other:
            return SIMD3<Float>(3, 3, 5)
        case .puffer:
            return SIMD3<Float>(3, 3, 5)
        }
    }
}

