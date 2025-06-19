//
//  CoreDataManager+Bookmark.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

import Foundation
import CoreData

extension CoreDataManager {

    static func createBookmark(contentID: String,
                               title: String, thumbnailImageURL: String?) {
        let context = CoreDataManager.shared.context
        let bookmark = BookmarkEntity(context: context)
        bookmark.contentID = contentID
        bookmark.title = title
        bookmark.createdAt = Date()
        bookmark.thumbnailImageURL = thumbnailImageURL
        
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
    
    static func updateBookmark(_ bookmark: BookmarkEntity, title: String, thumbnailImageURL: String) {
        bookmark.title = title
        bookmark.thumbnailImageURL = thumbnailImageURL
           
        CoreDataManager.shared.saveContext()
    }
    
    func deleteBookmark(by contentID: String) {
        let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "contentID == %@", contentID as CVarArg)

        do {
            let results = try context.fetch(request)
            if let bookmarkToDelete = results.first {
                context.delete(bookmarkToDelete)
                saveContext()
            }
        } catch {
            print("삭제 실패: \(error.localizedDescription)")
        }
    }
    
    func isBookmarked(contentID: String) -> Bool {
        let request: NSFetchRequest<BookmarkEntity> = BookmarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "contentID == %@", contentID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("isBookmarked fetch 실패: \(error.localizedDescription)")
            return false
        }
    }

}
