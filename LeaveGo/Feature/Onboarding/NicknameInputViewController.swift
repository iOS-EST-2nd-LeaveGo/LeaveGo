//
//  NicknameInputViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

class NicknameInputViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: UITextField!

    @IBOutlet weak var saveButton: UIButton!

    @IBAction func saveNickname(_ sender: Any) {
        let nickname = nicknameTextField.text ?? ""

        if Validation.isValidNickname(nickname) {
            UserSetting.shared.nickname = nickname
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false

        nicknameTextField.layer.cornerRadius = 10
        nicknameTextField.layer.borderWidth = 1
        nicknameTextField.layer.borderColor = UIColor.lightGray.cgColor

        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        saveButton.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        nicknameTextField.setLeftPadding(60)

        nicknameTextField.becomeFirstResponder()
    }

    func textFieldDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        saveButton.isEnabled = Validation.isValidNickname(text)
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
