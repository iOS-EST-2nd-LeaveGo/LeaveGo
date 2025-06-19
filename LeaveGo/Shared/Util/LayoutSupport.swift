//
//  LayoutSupport.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/9/25.
//

import Foundation

/// addSubviews, setupSubviewsConstraints을 구현한 다음 LifeCycle에서 configureSubviews를 호출해주세요.
///UIView type's default configure
protocol LayoutSupport {
    
    /// Combine setupview's all configuration
    func configureSubviews()
    
    /// Add view to view's subview
    func addSubviews()
    
    ///Use ConfigureUI.setupConstraints(detail:apply:)
    func setupSubviewsConstraints()
    
}

extension LayoutSupport {
    
    func configureSubviews() {
        addSubviews()
        setupSubviewsConstraints()
    }
    
}

protocol SetupSubviewsLayouts {
    // 잘 안씀
    ///Use ConfigureUI.setupLayout(detail:apply:)
    func setupSubviewsLayouts()
    
}

protocol SetupSubviewsConstraints {
    
    ///Use ConfigureUI.setupConstraints(detail:apply:)
    func setupSubviewsConstraints()
    
}
