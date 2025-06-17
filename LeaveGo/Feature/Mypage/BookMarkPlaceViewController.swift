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
        
        cell.delegate = self
        cell.setCell(model: placeModelList[indexPath.row], mode: .list(isBookmarked: true))
        // 항상 isBookmarked true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "삭제") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "북마크 삭제", message: "이 장소를 북마크에서 정말로 삭제하시겠습니까?", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "삭제", style: .default) { _ in
                let contentId = self.placeModelList[indexPath.row].contentId
                CoreDataManager.shared.deleteBookmark(by: contentId)
                
                self.placeModelList.remove(at: indexPath.row)
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            alert.addAction(confirmAction)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            self.present(alert, animated: true)
            
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

// MARK: ListTableViewCellDelegate
extension BookMarkPlaceViewController: ListTableViewCellDelegate {
    
    func didTapNavigation(cell: ListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let place = placeModelList[indexPath.row]
        
        // PlaceRoute.storyboard에서 뷰컨트롤러 인스턴스 생성
        let sb = UIStoryboard(name: "PlaceRoute", bundle: nil)
        guard let routeVC = sb.instantiateViewController(
            identifier: "PlaceRoute"
        ) as? PlaceRouteViewController else {
            return
        }

        routeVC.destination = RouteDestination(place: place)
        
        guard let nav = navigationController else {
            print("navigationController is nil")
            return
        }
        nav.pushViewController(routeVC, animated: true)
    }
    
    func didTapDeleteBookmark(cell: ListTableViewCell) {
        let alert = UIAlertController(title: "북마크 삭제", message: "이 장소를 북마크에서 정말로 삭제하시겠습니까?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "삭제", style: .default) { _ in
            if let placeModel = cell.place {
                let contentId = placeModel.contentId
                
                if let index = self.placeModelList.firstIndex(where: { contentId == $0.contentId }) {
                    
                    CoreDataManager.shared.deleteBookmark(by: contentId)
                    
                    self.placeModelList.remove(at: index)
                    
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true)
    }
    
}
