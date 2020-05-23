//
//  TraceProgressSection.swift
//  ARrehab
//
//  Created by Eric Wang on 5/3/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit
import MultiProgressView

class TraceProgressSection: ProgressViewSection {
    private let rightBorder: UIView = {
        let border = UIView()
        border.backgroundColor = .white
        return border
    }()
    
    func configure(withTraceTargetType traceTargetType: TraceTargetType) {
//        addSubview(rightBorder)
//        rightBorder.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, width: 1)
        backgroundColor = traceTargetType.color
    }
}
