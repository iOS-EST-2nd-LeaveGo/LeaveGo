//
//  MapHeaderView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import UIKit

class MapHeaderView: UIView {
  
  // MARK: Properties
  var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBackground
    return view
  }()
   var stackView: UIStackView = {
     let stackView = UIStackView()
     stackView.axis = .vertical
     stackView.alignment = .center
     stackView.distribution = .fill
     stackView.spacing = 16
     stackView.backgroundColor = .systemBackground
     return stackView
   }()
  var searchTextFieldBackbroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 10
    view.backgroundColor = .systemGray5
    return view
  }()
   var searchTextField: UITextField = {
     let textField = UITextField()
     textField.placeholder = "장소 이름, 태그로 검색하세요"
     return textField
   }()
   var displaySegmented: UISegmentedControl = {
     // TODO: 시간이 남으면 custom 해보자
     let segmentedControl = UISegmentedControl(items: ["리스트로 보기", "지도로 보기"])
     segmentedControl.selectedSegmentIndex = 0
     return segmentedControl
   }()
  
  // MARK: LifeCycle
    init() {
      super.init(frame: .zero)
      
      configureSubviews()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
  // TODO: displaySegmented에 의해 ListView <-> MapView 전환
  
}

// MARK: LayoutSupport
extension MapHeaderView: LayoutSupport {
  func addSubviews() {
    self.addSubview(containerView)
    
    containerView.addSubview(stackView)
    
    stackView.addArrangedSubview(searchTextFieldBackbroundView)
    stackView.addArrangedSubview(displaySegmented)
    
    searchTextFieldBackbroundView.addSubview(searchTextField)
  }
  
  func setupSubviewsConstraints() {
    containerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: self.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
    ])
    
    searchTextFieldBackbroundView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      searchTextFieldBackbroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      searchTextFieldBackbroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      searchTextFieldBackbroundView.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    searchTextField.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      searchTextField.centerYAnchor.constraint(equalTo: searchTextFieldBackbroundView.centerYAnchor),
      searchTextField.leadingAnchor.constraint(equalTo: searchTextFieldBackbroundView.leadingAnchor, constant: 16),
      searchTextField.trailingAnchor.constraint(equalTo: searchTextFieldBackbroundView.trailingAnchor, constant: -16)
    ])
  }
  
}

#Preview {
  MapHeaderView()
}
