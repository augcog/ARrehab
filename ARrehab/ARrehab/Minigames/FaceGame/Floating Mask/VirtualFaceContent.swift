//
//  VirtualFaceContent.swift
//  ARrehab
//
//  Created by Alan Zhang on 2020/6/6.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

protocol VirtualFaceContent {
    func update(withFaceAnchor: ARFaceAnchor)
}

typealias VirtualFaceNode = VirtualFaceContent & SCNNode

// MARK: Loading Content

func loadedContentForAsset(named resourceName: String) -> SCNNode {
    let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets")!
    let node = SCNReferenceNode(url: url)!
    node.load()
    
    return node
}
