//
//  PlacesViewController.swift
//  LeaveGo
//
//  Created by 박동언 on 6/8/25.
//

import UIKit

/// 관광지 리스트를 보여주는 화면을 담당하는 뷰 컨트롤러입니다.
/// - UITableView를 이용해 관광지를 리스트 형식으로 표시합니다.
/// - API를 호출하여 장소 정보를 불러오고 테이블 뷰에 반영합니다.
class PlacesViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var places: [PlaceList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// ListTableViewCell.xib 재사용 가능한 셀을 Scene에 띄우기
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        Task {
            // 탭바에 지도 누르면  임의 장소 설정(mapX, mapY)  및 현재 위치 중심 반경(radius) 입력
            await runAPITestForLocationBasedEndpoint(mapX: 127.0541534400073, mapY: 37.73755263999631, radius: 2000)
        }
    }
    
    /// 관광지 정보를 API로부터 가져오는 함수입니다.
    func runAPITestForLocationBasedEndpoint(mapX: Double, mapY: Double, radius: Int) async {
        // API_KEY 값 언래핑
        guard let apikey = Bundle.main.apiKey else { return }
        
        let baseUrl = "https://apis.data.go.kr/B551011/KorService2/locationBasedList2?MobileOS=IOS&MobileApp=LeaveGo&_type=json"
        
        guard let url = URL(string: "\(baseUrl)&mapX=\(mapX)&mapY=\(mapY)&radius=\(radius)&serviceKey=\(apikey)") else { return }
        
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                
                do {
                    let responseRoot = try decoder.decode(ResponseRoot<PlaceList>.self, from: data)
                    print("🙆‍♀️ API 호출 성공: \n\(responseRoot.response.body.items.item)")
                    
                    DispatchQueue.main.async {
                        self.places = responseRoot.response.body.items.item
                        self.tableView.reloadData()
                    }
                } catch {
                    print("😵 Decode 에러: \(error)")
                }
            default:
                print("😵 HTTP 오류 코드: \(httpResponse.statusCode)")
                return
            }
        } catch {
            print("😵 네트워크 오류: \(error)")
        }
    }
    
}

extension PlacesViewController: UITableViewDataSource {
    /// 테이블 뷰의 셀 개수를 반환합니다.
    /// - Returns: places 배열의 요소 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    /// 테이블 뷰 셀을 구성합니다.
    /// - 각 셀에 장소 제목, 거리, 시간, 이미지 정보를 표시합니다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }

        let place = places[indexPath.row]
        // 제목
        cell.titleLabel.text = place.title
        // 거리 (Int로 변환)
        cell.distanceLabel.text = "\(Int(Double(place.dist) ?? 0))m 떨어짐"
        // 간단한 시간 정보 (추후 detailIntro2 API로 대체 가능)
        cell.timeLabel.text = "09:00 ~ 18:00 • 1시간"

        // 이미지 처리
        // 1. PlaceList의 thumbnailImage는 String? 타입이므로 nil인지 확인
        // 2. nil이 아니고 빈 문자열이 아닌 경우, URL 생성 시도
        if let thumbnail = place.thumbnailImage,
           !thumbnail.isEmpty,
           let imageUrl = URL(string: thumbnail) {
            
            // 3. 백그라운드 스레드에서 네트워크 작업 시작
            DispatchQueue.global().async {
                // 4. try? 로 이미지 데이터를 네트워크에서 가져오기 시도 (예외 발생 시 nil 반환)
                if let data = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: data) {
                    // 5. 이미지 생성 성공 시, 메인 스레드에서 셀의 이미지 뷰에 설정
                    DispatchQueue.main.async {
                        cell.thumbnailImageView.image = image
                    }
                } else {
                    // 6. 데이터 가져오기나 이미지 생성 실패 시, 기본 이미지로 대체 (메인 스레드)
                    DispatchQueue.main.async {
                        cell.thumbnailImageView.image = UIImage(named: "placeholder")
                    }
                }
            }
        } else {
            // 7. thumbnailImage가 nil이거나 빈 문자열인 경우, 기본 이미지 표시
            cell.thumbnailImageView.image = UIImage(named: "placeholder")
        }

        return cell
    }
}
