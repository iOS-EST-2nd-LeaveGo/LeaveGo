//
//  CustomAlertView.swift
//  LeaveGo
//
//  Created by Nat Kim on 6/18/25.
//

import UIKit

class CustomAlertView: UIView {
	// MARK: - Subviews
	private let backgroundView: UIView = {
		let v = UIView()
		v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		v.alpha = 0
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()

	private let containerView: UIView = {
		let v = UIView()
		v.backgroundColor = .systemBackground
		v.layer.cornerRadius = 12
		v.clipsToBounds = true
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()

	private let messageLabel: UILabel = {
		let lbl = UILabel()
		lbl.textAlignment = .center
		lbl.numberOfLines = 0
		lbl.font = .systemFont(ofSize: 16)
		lbl.translatesAutoresizingMaskIntoConstraints = false
		return lbl
	}()

	private let buttonStack = UIStackView()
	
	// MARK: - Init
	init(message: String,
		 confirmTitle: String = "확인",
		 cancelTitle: String? = "취소",
		 confirmAction: @escaping () -> Void,
		 cancelAction: (() -> Void)? = nil) {
		super.init(frame: .zero)
		translatesAutoresizingMaskIntoConstraints = false

		messageLabel.text = message

		// 버튼 스택뷰 세팅
		buttonStack.axis = .horizontal
		buttonStack.distribution = .fillEqually
		buttonStack.spacing = 1
		buttonStack.translatesAutoresizingMaskIntoConstraints = false

		// 취소 버튼
		if let cancel = cancelTitle {
			let btn = makeButton(title: cancel, style: .plain) {
				cancelAction?()
				self.dismiss()
			}
			buttonStack.addArrangedSubview(btn)
		}

		// 확인 버튼
		let confirmBtn = makeButton(title: confirmTitle, style: .bold) {
			confirmAction()
			self.dismiss()
		}
		buttonStack.addArrangedSubview(confirmBtn)

		// 뷰 계층
		addSubview(backgroundView)
		addSubview(containerView)
		containerView.addSubview(messageLabel)
		containerView.addSubview(buttonStack)

		// layout
		NSLayoutConstraint.activate([
			// 배경
			backgroundView.topAnchor.constraint(equalTo: topAnchor),
			backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
			backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
			backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

			// 컨테이너 사이즈
			containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
			containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
			containerView.widthAnchor.constraint(equalToConstant: 270),

			// 메시지
			messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
			messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

			// 버튼 스택
			buttonStack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
			buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			buttonStack.heightAnchor.constraint(equalToConstant: 44),
			buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])

		// 초기 alpha
		self.alpha = 0
	}

	required init?(coder: NSCoder) { fatalError() }

	// MARK: - Helpers
	private func makeButton(title: String,
							style: ButtonStyle,
							action: @escaping () -> Void) -> UIButton {
		let btn = UIButton(type: .system)
		btn.setTitle(title, for: .normal)
		btn.titleLabel?.font = style == .bold
			? .boldSystemFont(ofSize: 17)
			: .systemFont(ofSize: 17)
		btn.backgroundColor = style == .bold ? .myAccent : .clear
		btn.setTitleColor(style == .bold ? .white : .myAccent, for: .normal)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.addAction(UIAction { _ in action() }, for: .touchUpInside)
		return btn
	}

	private enum ButtonStyle { case plain, bold }

	private func dismiss() {
		UIView.animate(withDuration: 0.2, animations: {
			self.alpha = 0
		}) { _ in
			self.removeFromSuperview()
		}
	}

	// MARK: - Show
	func show(on parent: UIViewController) {
		guard let parentView = parent.view else { return }
		parentView.addSubview(self)
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: parentView.topAnchor),
			leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
			trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
			bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
		])

		// 애니메이션
		UIView.animate(withDuration: 0.2) {
			self.backgroundView.alpha = 1
			self.alpha = 1
		}
	}
}

