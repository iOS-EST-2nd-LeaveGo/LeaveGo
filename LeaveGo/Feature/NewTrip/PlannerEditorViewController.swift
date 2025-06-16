//
//  AddNewTripViewController.swift
//  LeaveGo
//
//  Created by 김효환 on 6/12/25.
//

import UIKit
import PhotosUI


class PlannerEditorViewController: UIViewController {

    
    @IBOutlet weak var tripName: UITextField!
    @IBOutlet weak var tripThumbnail: UIImageView!
    @IBOutlet weak var thumbnailAdd: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func thumbnailAddAction(_ sender: Any) {
        
        var config = PHPickerConfiguration()
          config.selectionLimit = 1  // 하나만 선택
          config.filter = .images    // 이미지만

          let picker = PHPickerViewController(configuration: config)
          picker.delegate = self
          present(picker, animated: true)
      }
        
    }
    

extension PlannerEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) //사진 선택시 화면 닫기

        // 유저가 마지막으로 선택한 사진이 불러와진다면 provider에 저장
        guard let provider = results.last?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let selectedImage = image as? UIImage, error == nil else {
                return
        }

        DispatchQueue.main.async {
            self.tripThumbnail.image = selectedImage

            // 이미지가 잘 들어왔는지 확인용 로그
            print("✅ 썸네일 이미지 설정 완료")
            print("이미지 : \(selectedImage)")
            
            }
        }
    }
}

