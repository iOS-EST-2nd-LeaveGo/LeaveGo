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
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        UserSetting.shared.nickname = nickname
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
    // 
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
            saveNickname(self)
        }

        return true
    }
}
