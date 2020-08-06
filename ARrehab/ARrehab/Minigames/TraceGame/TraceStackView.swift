//
//  TraceStackView.swift
//  ARrehab
//
//  Created by Eric Wang on 5/3/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit

class TraceStackView: UIStackView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = colorViewHeight / 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private let colorViewHeight: CGFloat = 11
    
    init(traceTargetType: TraceTargetType) {
        super.init(frame: .zero)
        alignment = .fill
        spacing = 6
        
        addArrangedSubview(colorView)
        colorView.anchor(width: colorViewHeight, height: colorViewHeight)
        colorView.backgroundColor = traceTargetType.color
        
        addArrangedSubview(titleLabel)
        titleLabel.text = traceTargetType.description
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
