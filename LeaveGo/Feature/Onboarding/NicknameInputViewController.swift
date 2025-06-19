//
//  NicknameInputViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/9/25.
//

import UIKit

// MARK: - 닉네임 입력 및 수정 화면 (온보딩 & 마이페이지 재사용)
class NicknameInputViewController: UIViewController {
    // MARK: - 모드에 따라 온보딩 또는 수정 동작 분기
    var mode: NicknameMode = .onboarding
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - 닉네임 저장 버튼 액션
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
        nicknameTextField.textContentType = .none
        
        saveButton.layer.cornerRadius = 16
        saveButton.clipsToBounds = true
        
        // 키보드 숨기기 위한 탭 제스처
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        // 모드에 따라 UI 구성 분기
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
    
    // MARK: - 입력값 변경 시 유효성 검사
    func textFieldDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        saveButton.isEnabled = Validation.isValidNickname(text)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate: 리턴 키 처리 및 실시간 유효성 검사
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

// MARK: - 제스처가 버튼 등 UIControl에 방해되지 않도록 설정
extension NicknameInputViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
