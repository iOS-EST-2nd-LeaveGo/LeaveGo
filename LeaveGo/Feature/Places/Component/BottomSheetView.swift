//
//  BottomSheetView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/10/25.
//

//
//  TrashDetailViewController.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/07/20.
//

import MapKit
import UIKit

final class BottomSheetView: UIView {

    // MARK: - Properties
    private let handleView = UIView()
    private var topConstraint: NSLayoutConstraint!
    private var panStartTopConstant: CGFloat = 0.0

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHandle()
        setupPanGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupHandle()
        setupPanGesture()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 5
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupHandle() {
        handleView.backgroundColor = .lightGray
        handleView.layer.cornerRadius = 3
        handleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(handleView)
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)

        switch gesture.state {
        case .began:
            panStartTopConstant = topConstraint.constant

        case .changed:
            let newConstant = panStartTopConstant + translation.y
            topConstraint.constant = max(newConstant, 0)

        case .ended:
            let isDismiss = velocity.y > 500
            animate(toDismiss: isDismiss)

        default: break
        }
    }

    private func animate(toDismiss: Bool) {
        let target: CGFloat = toDismiss ? superview!.bounds.height : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
          self.topConstraint.constant = target
          self.superview?.layoutIfNeeded()
        }
    }

    // MARK: - Public show/hide
    func attach(to parent: UIViewController, height: CGFloat) {
        guard let parentView = parent.view else { return }
        parentView.addSubview(self)

        topConstraint = topAnchor.constraint(equalTo: parentView.bottomAnchor)
        NSLayoutConstraint.activate([
            topConstraint,
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            heightAnchor.constraint(equalToConstant: height)
        ])
        parentView.layoutIfNeeded()
    }

    func show() {
        topConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }

    func dismiss() {
        topConstraint.constant = superview!.bounds.height
        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
}
