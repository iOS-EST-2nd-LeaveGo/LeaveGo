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

    var places: [Place] = []

    /// 뷰가 메모리에 로드된 후 호출되며, 테이블 뷰 설정 및 데이터 로드를 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

        fetchPlaceList()
    }

    /// 관광지 정보를 API로부터 가져오는 함수입니다.
    /// - 성공 시 places 배열에 데이터를 저장하고 테이블 뷰를 갱신합니다.
    func fetchPlaceList() {
        // MARK: - 더미 데이터 사용 (API 호출은 주석 처리됨)
        // ⚠️ 이 더미 데이터는 테스트 용도로만 사용됩니다. 실제 배포 시 반드시 제거하세요.
        let dummyJSON = """
        {
          "response": {
            "header": {
              "resultCode": "0000",
              "resultMsg": "OK"
            },
            "body": {
              "items": {
                "item": [
                  {
                    "addr1": "서울특별시 중구 퇴계로34길 28 (필동2가)",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A02",
                    "cat2": "A0201",
                    "cat3": "A02010600",
                    "contentid": "126747",
                    "contenttypeid": "12",
                    "dist": "940.5178321606905",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/36/3083836_image2_1.JPG",
                    "mapx": "126.9932865315",
                    "mapy": "37.5597775194",
                    "tel": "",
                    "title": "남산골한옥마을"
                  },
                  {
                    "addr1": "서울특별시 종로구 세종대로 149",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A04",
                    "cat2": "A0401",
                    "cat3": "A04010400",
                    "contentid": "132178",
                    "contenttypeid": "38",
                    "dist": "962.34",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/41/2589341_image2_1.jpg",
                    "mapx": "126.9761544804",
                    "mapy": "37.5696232899",
                    "tel": "02-399-3270",
                    "title": "동화면세점"
                  },
                  {
                    "addr1": "서울특별시 중구 태평로1가",
                    "addr2": "청계광장",
                    "areacode": "1",
                    "cat1": "A02",
                    "cat2": "A0207",
                    "cat3": "A02070200",
                    "contentid": "3495363",
                    "contenttypeid": "15",
                    "dist": "835.94",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/48/3495348_image2_1.jpg",
                    "mapx": "126.9777682330",
                    "mapy": "37.5692566951",
                    "tel": "02-797-8760",
                    "title": "경북 WOW(와)보이소"
                  },
                  {
                    "addr1": "서울특별시 중구 세종대로21길 49",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A05",
                    "cat2": "A0502",
                    "cat3": "A05020300",
                    "contentid": "1966366",
                    "contenttypeid": "39",
                    "dist": "936.68",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/18/1966218_image2_1.jpg",
                    "mapx": "126.9756156641",
                    "mapy": "37.5688094861",
                    "tel": "02-736-1001",
                    "title": "오양회참치"
                  },
                  {
                    "addr1": "서울특별시 중구 남대문시장길 25-8",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A04",
                    "cat2": "A0401",
                    "cat3": "A04010200",
                    "contentid": "132225",
                    "contenttypeid": "38",
                    "dist": "642.67",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/31/3065131_image2_1.JPG",
                    "mapx": "126.9775046150",
                    "mapy": "37.5605299268",
                    "tel": "02-752-1012",
                    "title": "남대문인삼시장"
                  },
                  {
                    "addr1": "서울특별시 중구 남대문시장4길 21",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A04",
                    "cat2": "A0401",
                    "cat3": "A04010600",
                    "contentid": "1013079",
                    "contenttypeid": "38",
                    "dist": "714.23",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/29/3083029_image2_1.JPG",
                    "mapx": "126.9776685255",
                    "mapy": "37.5592411902",
                    "tel": "02-779-2951",
                    "title": "숭례문 수입상가"
                  },
                  {
                    "addr1": "서울특별시 중구 남대문시장8길 7",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A04",
                    "cat2": "A0401",
                    "cat3": "A04010600",
                    "contentid": "1019638",
                    "contenttypeid": "38",
                    "dist": "565.61",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/57/3064057_image2_1.JPG",
                    "mapx": "126.9788489464",
                    "mapy": "37.5601966561",
                    "tel": "1566-4578",
                    "title": "삼익패션타운"
                  },
                  {
                    "addr1": "서울특별시 중구 남대문로 6-2",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A04",
                    "cat2": "A0401",
                    "cat3": "A04010600",
                    "contentid": "985961",
                    "contenttypeid": "38",
                    "dist": "732.26",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/80/3064080_image2_1.JPG",
                    "mapx": "126.9764713804",
                    "mapy": "37.5603577058",
                    "tel": "02-753-2805",
                    "title": "남대문 문구상가"
                  },
                  {
                    "addr1": "서울특별시 중구 남대문시장4길 21",
                    "addr2": "",
                    "areacode": "1",
                    "cat1": "A04",
                    "cat2": "A0401",
                    "cat3": "A04010200",
                    "contentid": "132180",
                    "contenttypeid": "38",
                    "dist": "713.08",
                    "firstimage": "http://tong.visitkorea.or.kr/cms/resource/67/2612867_image2_1.jpg",
                    "mapx": "126.9776796357",
                    "mapy": "37.5592467455",
                    "tel": "",
                    "title": "남대문시장"
                  }
                ]
              },
              "numOfRows": 10,
              "pageNo": 1,
              "totalCount": 604
            }
          }
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(APIResponse.self, from: dummyJSON)
            self.places = apiResponse.response.body.items.item

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("더미 데이터 디코딩 실패: \(error.localizedDescription)")
        }

        /*
        // MARK: - 실제 API 호출 로직 (주석 처리됨)
        guard let serviceKey = self.loadAPIKey(),
              let url = URL(string: "https://apis.data.go.kr/B551011/KorService2/locationBasedList2?serviceKey=\(serviceKey)&numOfRows=10&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json&arrange=C&mapX=126.98375&mapY=37.563446&radius=1000&areaCode=1")
        else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("API 호출 실패: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(APIResponse.self, from: data)
                self.places = apiResponse.response.body.items.item

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("디코딩 실패: \(error.localizedDescription)")
            }
        }

        task.resume()
        */
    }
    /// Secrets.plist 파일에서 API 키를 불러옵니다.
    /// - Returns: API 키 문자열 (옵셔널)
    func loadAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["API_KEY"] as? String else {
            print("API 키 로드 실패")
            return nil
        }
        return key
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
        cell.titleLabel.text = place.title
        cell.distanceLabel.text = "\(Int(Double(place.dist) ?? 0))m 떨어짐"
        cell.timeLabel.text = "09:00 ~ 18:00 • 1시간"

        // 📌 이미지 URL이 http일 경우 https로 치환 (ATS 정책 회피용, 보안 문제 방지)
        if let imageUrlString = place.firstimage {
            let secureUrlString = imageUrlString.replacingOccurrences(of: "http://", with: "https://")
            if let url = URL(string: secureUrlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.thumbnailImageView.image = image
                            // ⚠️ 임시로 이미지 크기 확대 (테스트용, 나중에 삭제 가능)
                            cell.thumbnailImageView.frame.size = CGSize(width: 100, height: 100)
                            cell.thumbnailImageView.contentMode = .scaleAspectFill
                            cell.thumbnailImageView.clipsToBounds = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.thumbnailImageView.image = UIImage(systemName: "photo")
                        }
                    }
                }
            } else {
                cell.thumbnailImageView.image = UIImage(systemName: "photo")
            }
        } else {
            cell.thumbnailImageView.image = UIImage(systemName: "photo")
        }

        return cell
    }
}
