//
//  BottomSheetView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/10/25.
//

import MapKit
import UIKit

final class BottomSheetView: PassThroughView {
    // MARK: UI 구성 요소
    private let sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let handlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        view.layer.cornerRadius = 3
        return view
    }()
    let stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.alignment = .center
        stackview.distribution = .fillEqually
        stackview.spacing = 10
        return stackview
    }()
    let directionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        return button
    }()
    let spacingView1: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    let spacingView2: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        configureSubviews()
        addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget() {
        directionButton.addTarget(self, action: #selector(tappedDirectionButton), for: .touchUpInside)
    }
    
    @objc func tappedDirectionButton() {
        // TODO: RoutePlaces 호출
        print("tappedDirectionButton")
    }
    
}

// MARK: LayoutSupport
extension BottomSheetView: LayoutSupport {
    
    func addSubviews() {
        addSubview(sheetView)
        
        sheetView.addSubview(handlerView)
        sheetView.addSubview(stackview)
        
        stackview.addArrangedSubview(spacingView1)
        stackview.addArrangedSubview(directionButton)
        stackview.addArrangedSubview(spacingView2)
    }
    
    func setupSubviewsConstraints() {
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            sheetView.rightAnchor.constraint(equalTo: self.rightAnchor),
            sheetView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            sheetView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            handlerView.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 8),
            handlerView.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            handlerView.widthAnchor.constraint(equalToConstant: 40),
            handlerView.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        stackview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: handlerView.bottomAnchor, constant: 8),
            stackview.leadingAnchor.constraint(equalTo: handlerView.leadingAnchor, constant: 10),
            stackview.trailingAnchor.constraint(equalTo: handlerView.trailingAnchor, constant: 10)
            ])
        
        directionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            directionButton.heightAnchor.constraint(equalToConstant: 44),
            directionButton.widthAnchor.constraint(equalToConstant: 44)
            ])
    }
    
}
