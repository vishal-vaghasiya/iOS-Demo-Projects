//
//  BottomSheetController.swift
//  VishalDemoProject
//
//  Created by Nexios Technologies on 06/08/25.
//

import UIKit

/*
 let memberVC = StoryboardScene.Circle.memberVC.instantiate()
 let bottomSheet = BottomSheetController(contentViewController: memberVC)
 present(bottomSheet, animated: false)
 */

public final class BottomSheetController: UIViewController {

    // MARK: - Detents
    public enum Detent {
        case collapsed
        case medium
        case full

        func height(in view: UIView) -> CGFloat {
            switch self {
            case .collapsed: return 100
            case .medium: return 300
            case .full: return view.bounds.height - (view.safeAreaInsets.top + 60)
            }
        }
    }

    // MARK: - Properties

    private let contentViewController: UIViewController
    private let containerView = UIView()
    private var topConstraint: NSLayoutConstraint!
    private var currentDetent: Detent = .collapsed

    // MARK: - Initializer

    public init(contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupSheet()
    }

    // MARK: - Setup

    private func setupSheet() {
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true

        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let initialHeight = Detent.collapsed.height(in: view)
        let fullHeight = Detent.full.height(in: view)

        topConstraint = containerView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -initialHeight)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topConstraint,
            containerView.heightAnchor.constraint(equalToConstant: fullHeight)
        ])

        // Embed child VC
        addChild(contentViewController)
        containerView.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        contentViewController.didMove(toParent: self)

        // Grabber
        let grabber = UIView()
        grabber.backgroundColor = .systemGray3
        grabber.layer.cornerRadius = 3
        grabber.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(grabber)

        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            grabber.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 50),
            grabber.heightAnchor.constraint(equalToConstant: 5)
        ])

        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
    }

    // MARK: - Gesture

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .changed:
            let newTop = topConstraint.constant + translation.y
            topConstraint.constant = min(max(-Detent.full.height(in: view) + 60, newTop), -Detent.collapsed.height(in: view))
            gesture.setTranslation(.zero, in: view)

        case .ended:
            let velocity = gesture.velocity(in: view).y
            let finalDetent: Detent

            if velocity > 400 {
                finalDetent = .collapsed
            } else if velocity < -400 {
                finalDetent = .full
            } else {
                let current = abs(topConstraint.constant)
                if current < 150 {
                    finalDetent = .collapsed
                } else if current < Detent.full.height(in: view) / 2 {
                    finalDetent = .medium
                } else {
                    finalDetent = .full
                }
            }

            animateTo(detent: finalDetent)

        default:
            break
        }
    }

    // MARK: - Public Control

    public func animateTo(detent: Detent) {
        currentDetent = detent
        topConstraint.constant = -detent.height(in: view)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [.curveEaseOut]) {
            self.view.layoutIfNeeded()
        }
    }
}
