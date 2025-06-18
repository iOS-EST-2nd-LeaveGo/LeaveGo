//
//  NicknameInputViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class NicknameInputViewController: UIViewController {
    var mode: NicknameMode = .onboarding

    @IBOutlet weak var titleLabel: UILabel!


    @IBOutlet weak var nicknameTextField: UITextField!

    @IBOutlet weak var saveButton: UIButton!

    @IBAction func saveNickname(_ sender: Any) {
        let nickname = nicknameTextField.text ?? ""

        if Validation.isValidNickname(nickname) {
            UserSetting.shared.nickname = nickname
        }

        switch mode {
        case .onboarding:
            performSegue(withIdentifier: "goToTransportSegue", sender: nil)
        case .editing:
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nicknameTextField.layer.cornerRadius = 16
//        nicknameTextField.layer.borderWidth = 1
//        nicknameTextField.layer.borderColor = UIColor.accent.cgColor

        saveButton.layer.cornerRadius = 16
        saveButton.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false  // 터치 이벤트 전달되게
        view.addGestureRecognizer(tap)

        switch mode {
        case .onboarding:
            nicknameTextField.text = ""
            nicknameTextField.placeholder = "닉네임을 입력해주세요"
            saveButton.isEnabled = false
        case .editing:
            if let nickname = UserSetting.shared.nickname, !nickname.isEmpty {
                nicknameTextField.text = nickname
                saveButton.isEnabled = Validation.isValidNickname(nickname)
            } else {
                nicknameTextField.text = ""
                nicknameTextField.placeholder = "닉네임을 입력해주세요"
                saveButton.isEnabled = false
            }

            navigationItem.title = "닉네임 변경"

            titleLabel.isHidden = true

            saveButton.setTitle("변경", for: .normal)
            saveButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)

        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nicknameTextField.becomeFirstResponder()
    }

    func textFieldDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        saveButton.isEnabled = Validation.isValidNickname(text)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension NicknameInputViewController: UITextFieldDelegate {
    // 입력한 닉네임 검증하고 버튼 활성화/비활성화
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
          saveButton.isEnabled = Validation.isValidNickname(text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nickname = nicknameTextField.text ?? ""

        if Validation.isValidNickname(nickname) {
            saveButton.sendActions(for: .touchUpInside)
            saveButton.resignFirstResponder()
        }

        return true
    }
}
