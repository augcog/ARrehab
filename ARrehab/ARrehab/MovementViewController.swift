//
//  TraceViewController.swift
//  ARrehab
//
//  Created by Eric Wang on 5/2/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit
import Combine
import MultiProgressView

/**
 Movement Minigame ViewController.
 */
class MovementGameViewController : MinigameViewController {
    
    /// Progress subscribers
    var subscribers: [Cancellable] = []
    
    private let backgroundView: UIView = {
        let view = PassThroughView()
//        view.backgroundColor = .white
//        view.layer.borderColor = UIColor.darkGray.cgColor
//        view.layer.borderWidth = 0.5
        return view
    }()
    
    private lazy var progressView: MultiProgressView = {
        let progress = MultiProgressView()
        progress.trackBackgroundColor = UIColor.white
        progress.lineCap = .round
        progress.cornerRadius = progressViewHeight / 4
        return progress
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .equalSpacing
        sv.alignment = .center
        return sv
    }()
    
    private let iPhoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Progress"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
//    private let dataUsedLabel: UILabel = {
//        let label = UILabel()
//        label.text = "0 GB of 64 GB Used"
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .gray
//        return label
//    }()
    
    private let padding: CGFloat = 15
    private let progressViewHeight: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              left: view.safeAreaLayoutGuide.leftAnchor,
                              right: view.safeAreaLayoutGuide.rightAnchor,
                              paddingTop: 50)
        
        setupLabels()
        setupProgressBar()
        setupStackView()
        addProgressSubscriber()
    }
    
    private func setupLabels() {
        backgroundView.addSubview(iPhoneLabel)
        iPhoneLabel.anchor(top: backgroundView.topAnchor,
                           left: backgroundView.leftAnchor,
                           paddingTop: padding,
                           paddingLeft: padding)
//
//        backgroundView.addSubview(dataUsedLabel)
//        dataUsedLabel.anchor(top: backgroundView.topAnchor,
//                             right: backgroundView.rightAnchor,
//                             paddingTop: padding,
//                             paddingRight: padding)
    }
    
    private func setupProgressBar() {
        backgroundView.addSubview(progressView)
        progressView.anchor(top: iPhoneLabel.bottomAnchor,
                            left: backgroundView.leftAnchor,
                            right: backgroundView.rightAnchor,
                            paddingTop: padding,
                            paddingLeft: padding,
                            paddingRight: padding,
                            height: progressViewHeight)
        progressView.dataSource = self
        progressView.delegate = self
    }
    
    private func setupStackView() {
        backgroundView.addSubview(stackView)
        stackView.anchor(top: progressView.bottomAnchor,
                         left: backgroundView.leftAnchor,
                         bottom: backgroundView.bottomAnchor,
                         right: backgroundView.rightAnchor,
                         paddingTop: padding,
                         paddingLeft: padding,
                         paddingBottom: padding,
                         paddingRight: padding)

        // TODO FIXME
//        for type in (minigame as! MovementGame).targets {
////            if type != .unknown {
//                stackView.addArrangedSubview(TraceStackView(traceTargetType: type))
////            }
//        }
        stackView.addArrangedSubview(UIView())
    }
    
    private func animateProgress(progress: [Float]) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: .curveLinear,
                       animations: {
                        self.progressView.setProgress(section: 0, to: progress[0])
        })
//        dataUsedLabel.text = "56.5 GB of 64 GB Used"
    }
    
    private func resetProgress() {
        UIView.animate(withDuration: 0.1) {
            self.progressView.resetProgress()
        }
//        dataUsedLabel.text = "0 GB of 64 GB Used"
    }
    
    override func attachMinigame(minigame: Minigame) {
        super.attachMinigame(minigame: minigame)
        
        if self.isViewLoaded {
            // TODO cancel the previous score subscription
            addProgressSubscriber()
            setupStackView()
        }
    }
    
    func addProgressSubscriber() {
        guard minigame != nil else {
            return
        }
        
        subscribers.append(minigame!.$progress.sink(receiveValue: { (progress) in
            self.animateProgress(progress: progress)
        }))
    }
}

//MARK: - MultiProgressViewDataSource

extension MovementGameViewController: MultiProgressViewDataSource {
    public func numberOfSections(in progressBar: MultiProgressView) -> Int {
        return 1
    }
    
    public func progressView(_ progressView: MultiProgressView, viewForSection section: Int) -> ProgressViewSection {
        let bar = ProgressViewSection()
        // FIXME
        bar.backgroundColor = .blue
        return bar
    }
}

// MARK: - MultiProgressViewDelegate

extension MovementGameViewController: MultiProgressViewDelegate {
    
    func progressView(_ progressView: MultiProgressView, didTapSectionAt index: Int) {
        print("Tapped section \(index)")
    }
}