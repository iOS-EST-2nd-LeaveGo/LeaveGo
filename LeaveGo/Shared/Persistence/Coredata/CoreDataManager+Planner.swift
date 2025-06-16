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

    func deletePlanner(_ planner: PlannerEntity) {
        context.delete(planner)
        saveContext()
    }

}
