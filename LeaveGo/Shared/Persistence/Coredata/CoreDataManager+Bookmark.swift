//
//  CoreDataManager+Bookmark.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

import Foundation
import CoreData
import UIKit

extension CoreDataManager {

    static func createBookmark(contentID: String,
                        source: String, thumbnailImage: UIImage?) {
        let context = CoreDataManager.shared.context
        let bookmark = BookmarkEntity(context: context)
        bookmark.contentID = contentID
        bookmark.source = source
        bookmark.createdAt = Date()
        bookmark.id = UUID()
        if let thumbnailImage = thumbnailImage,  let thumnailIamge = thumbnailImage.jpegData(compressionQuality: 1.0) {
            bookmark.thumbnailImage = thumnailIamge
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func fetchAllBookmarks() -> [BookmarkEntity] {
        let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    static func updateBookmark(_ bookmark: BookmarkEntity, source: String, thumbnailImage: UIImage?) {
        bookmark.source = source
        if let thumbnailImage = thumbnailImage,  let thumnailIamge = thumbnailImage.jpegData(compressionQuality: 1.0) {
            bookmark.thumbnailImage = thumnailIamge
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func deleteBookmark(_ bookmark: BookmarkEntity) {
        CoreDataManager.shared.context.delete(bookmark)
        CoreDataManager.shared.saveContext()
    }
    
    // func isBookmarked

}
