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
//        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "북마크 장소 목록"
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let bookmarkEntities = CoreDataManager.shared.fetchAllBookmarks()
        placeModelList = bookmarkEntities.map { PlaceModel(from: $0) }
        tableView.reloadData()
    }
    
}

// MARK: UITableViewDelegate
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
            cell.distanceLabel.text = "\(distance)m 떨어짐"
        }
        
        cell.thumbnailImageView.image = place.thumbnailImage ?? UIImage(systemName: "photo.fill")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
