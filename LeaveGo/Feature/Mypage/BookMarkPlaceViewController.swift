//
//  BookMarkPlaceViewController.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/16/25.
//

import UIKit

class BookMarkPlaceViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var placeModelList: [PlaceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cell = UINib(nibName: "ListTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "ListTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "북마크 장소 목록"
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let bookmarkEntities = CoreDataManager.shared.fetchAllBookmarks()
        placeModelList = bookmarkEntities.map { PlaceModel(from: $0) }
        loadThumbnailImage()
        tableView.reloadData()
    }
    
    /// image를 load해서 PlaceModel에 미리 저장해둠
    func loadThumbnailImage() {

        _ = (0..<placeModelList.count).map { index in
            if let urlString = placeModelList[index].thumbnailURL, let url = URL(string: urlString) {

                fetchThumbnailImage(for: url) { [weak self] image in
                    guard let self = self else { return }
                    
                    /// image까지 완전히 load된 이후 완전체 Model을 VC들에게 전달합니다.
                    /// placeListVC의 tableView를 다시 그려줍니다.
                    self.placeModelList[index].thumbnailImage = image
                    
                    tableView.reloadData()
                }
            }
        }
    }

    func fetchThumbnailImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data), error == nil {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                print(error ?? "image fetch error")
            }
        }.resume()
    }
    
}

// MARK: UITableViewDataSource
extension BookMarkPlaceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeModelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setupMenu(mode: .list) // 임시로 .list설정
        
        let place = placeModelList[indexPath.row]
        
        cell.titleLabel.text = place.title
        
        if let distance = place.distance {
            cell.distanceLabel.text = "\(distance)m 떨어짐" // MapKit으로 계산
        }
        
        cell.thumbnailImageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "삭제") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
//            CoreDataManager.shared.deleteBookmark(placeModelList[indexPath.row].toBookmarkEntity())
            
            let uuid = placeModelList[indexPath.row].uuid
            CoreDataManager.shared.deleteBookmark(by: uuid)
            
            placeModelList.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
   
}

// MARK: UITableViewDelegate
extension BookMarkPlaceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
