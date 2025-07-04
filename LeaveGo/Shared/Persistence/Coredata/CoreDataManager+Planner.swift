//
//  CoreDataManager+Schedule.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

import Foundation
import CoreData
import UIKit

extension CoreDataManager {

    func createPlanner(title: String, startDate: Date, endDate: Date, thumbnailPath: String?) -> PlannerEntity {
        let planner = PlannerEntity(context: context)
        planner.id = UUID()
        planner.createdAt = Date()
        planner.title = title
        planner.startDate = startDate
        planner.endDate = endDate
        planner.thumbnailPath = thumbnailPath

		saveContext()

        return planner
    }

    func fetchAllPlanners() -> [PlannerEntity] {
        let request: NSFetchRequest<PlannerEntity> = PlannerEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("fetch 실패: \(error.localizedDescription)")
            return []
        }
    }

    // id를 전달 받아 해당 여행이 존재하는지 조회하는 메서드
    func fetchOnePlanner(id: UUID) -> PlannerEntity? {
        let request: NSFetchRequest<PlannerEntity> = PlannerEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            let result = try context.fetch(request)
            return result.first
        } catch {
            print("fetch 실패: \(error.localizedDescription)")
            return nil
        }
    }

    // 여행의 갯수를 반환하는 메서드
    func fetchPlannerCount() -> Int {
        let request: NSFetchRequest<PlannerEntity> = PlannerEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            let count = try context.count(for: request)
            return count
        } catch {
            return 0
        }
    }

    func updatePlanner(_ planner: PlannerEntity, title: String, startDate: Date, endDate: Date, thumbnailPath: String?) {
        planner.title = title
        planner.startDate = startDate
        planner.endDate = endDate
        planner.thumbnailPath = thumbnailPath
        saveContext()
    }
    
    func deletePlanner(id: UUID) {
        guard let planner = fetchOnePlanner(id: id) else { return }
        context.delete(planner)
        saveContext()
    }
}

extension CoreDataManager {
    func insertDummyData() {
#if DEBUG // 디버그 모드에서만 작동하도록 설정
        let dataList: [[String: Any]] = mockPlanners.map { planner in
            return [
                "id": UUID(),
                "title": planner.title,
                "thumbnailPath": planner.thumbnailPath as Any,
                "createdAt": Date.now,
                "startDate": Date.now,
                "endDate": Date(timeIntervalSinceNow: +1)
                // placeList는 아직 매핑 안 함 (별도 관계 필요)
            ]
        }

        let insertRequest = NSBatchInsertRequest(entityName: "Planner", objects: dataList)

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
