//
//  CoreDataManager.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

// MARK: - Core Data stack
import CoreData
import UIKit

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

extension CoreDataManager {
    func insertDummyData() {
#if DEBUG // 디버그 모드에서만 작동하도록 설정
        let dataList: [[String: Any]] = mockPlanners.map { planner in
            return [
                "title": planner.title,
                "thumbnailPath": planner.thumbnailPath as Any
                // placeList는 아직 매핑 안 함 (별도 관계 필요)
            ]
        }

        let insertRequest = NSBatchInsertRequest(entityName: "PlannerEntity", objects: dataList)

        do {
            if let result = try context.execute(insertRequest) as? NSBatchInsertResult,
               let succeeded = result.result as? Bool {
                if succeeded {
                    print("✅ Batch Insert 성공")
                } else {
                    print("❌ Batch Insert 실패")
                }
            }
        } catch {
            print("🔥 Batch Insert 에러: \(error.localizedDescription)")
        }
#endif
    }
}
