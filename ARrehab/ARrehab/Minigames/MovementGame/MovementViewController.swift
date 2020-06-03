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
    
    /// Coaching Image
    @IBOutlet var coachImageView: UIImageView!
    /// Progress subscribers
    var subscribers: [Cancellable] = []

    private let backgroundView: UIView = {
        let view = PassThroughView()
        return view
    }()

    private lazy var progressView: MultiProgressView = {
        let progress = MultiProgressView()
        progress.trackBackgroundColor = UIColor.white
        progress.lineCap = .round
        progress.cornerRadius = progressViewHeight / 4
        return progress
    }()
//
//    private let stackView: UIStackView = {
//        let sv = UIStackView()
//        sv.distribution = .equalSpacing
//        sv.alignment = .center
//        return sv
//    }()

    private let padding: CGFloat = 15
    private let progressViewHeight: CGFloat = 20
    private let progressViewWidth: CGFloat = 500

    override func viewDidLoad() {
        print("Loading SuperView")
        super.viewDidLoad()
        print("Super View did load. Adding custom elements")
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                left: view.safeAreaLayoutGuide.leftAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              //right: view.safeAreaLayoutGuide.rightAnchor,
                              paddingTop: 50,
                              paddingBottom: 50,
                              width: progressViewWidth
                            )
        backgroundView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        setupProgressBar()
//        setupStackView()
        addMinigameSubscriber()
        print("Complete viewDidLoad")
    }
    
    private func setupProgressBar() {
        backgroundView.addSubview(progressView)
        progressView.anchor(top: backgroundView.topAnchor,
                            left: backgroundView.leftAnchor,
                            //right: backgroundView.rightAnchor,
                            paddingTop: padding,
                            paddingLeft: padding,
                            paddingRight: padding,
                            width: progressViewWidth,
                            height: progressViewHeight)
        progressView.dataSource = self
        progressView.delegate = self
        //backgroundView.translatesAutoresizingMaskIntoConstraints = true
    }
//
//    private func setupStackView() {
//        backgroundView.addSubview(stackView)
//        stackView.anchor(top: progressView.bottomAnchor,
//                         left: backgroundView.leftAnchor,
//                         bottom: backgroundView.bottomAnchor,
//                         right: backgroundView.rightAnchor,
//                         paddingTop: padding,
//                         paddingLeft: padding,
//                         paddingBottom: padding,
//                         paddingRight: padding)
//
//        // TODO FIXME
////        for type in (minigame as! MovementGame).targets {
//////            if type != .unknown {
////                stackView.addArrangedSubview(TraceStackView(traceTargetType: type))
//////            }
////        }
//        stackView.addArrangedSubview(UIView())
//    }
//
    private func animateProgress(progress: [Float]) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: .curveLinear,
                       animations: {
                        self.progressView.setProgress(section: 0, to: progress[1])
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
            addMinigameSubscriber()
//            setupStackView()
        }
    }

    func addMinigameSubscriber() {
        guard minigame != nil else {
            return
        }

        subscribers.append(minigame!.$progress.sink(receiveValue: { (progress) in
            self.animateProgress(progress: progress)
        }))
        subscribers.append(minigame().$coachingState.sink(receiveValue: { (state) in
            // TODO
            self.coachImageView.image = state.image
        }))
    }
}

// MARK: - UtilityFunctions
extension MovementGameViewController {
    func minigame() -> MovementGame {
        return self.minigame as! MovementGame
    }
}

// MARK: - MultiProgressViewDataSource

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
