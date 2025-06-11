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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nicknameTextField.becomeFirstResponder()
    }
}

extension NicknameInputViewController: UITextFieldDelegate {
    // 입력한 닉네임 검증하고 버튼 활성화/비활성화
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nickname = nicknameTextField.text ?? ""

        guard let finalNickname = UITextField.replacingText(text: nickname, range: range, string: string) else {
            saveButton.isEnabled = false

            return true
        }

        saveButton.isEnabled = Validation.isValidNickname(finalNickname)

        return true
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
