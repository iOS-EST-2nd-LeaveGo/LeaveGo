//
//  CoreDataManager.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

// MARK: - Core Data stack
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext

    private init() {
        persistentContainer = NSPersistentContainer(name: "LeaveGo")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 여기를 배포용 앱에서는 사용자에게 메시지를 보여주는 등으로 대체해야 함
                print("CoreData 에러 발생 \(error.localizedDescription)")
                // Alert 띄우거나 오류 View 보여주기
            }
        })

        context = persistentContainer.viewContext

    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // 여기를 배포용 앱에서는 사용자에게 메시지를 보여주는 등으로 대체해야 함
                let error = error as NSError
                print("CoreData 저장 실패 \(error.localizedDescription)")
            }
        }
    }
}


