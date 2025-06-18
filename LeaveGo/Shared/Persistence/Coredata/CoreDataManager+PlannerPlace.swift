//
//  CoreDataManager+ScheduleItem.swift
//  LeaveGo
//
//  Created by 박동언 on 6/13/25.
//

import Foundation
import CoreData

extension CoreDataManager {

    // func fetchPlannerPlace
    // func updatePlannerPlace
    // func deletePlannerPlace

    // batchInsert 데이터 검증 필요
    // NSfetchedResultsController

    // 장소 추가
    func createPlannerPlace(
        to planner: PlannerEntity,
        date: Date,
        contentID: String,
        title: String, // ✅ title 추가
        thumbnailURL: String?,
        order: Int16
    ) -> PlannerPlaceEntity {
        let place = PlannerPlaceEntity(context: context)
        place.id = UUID()
        place.createdAt = Date()
        place.date = date
        place.contentID = contentID
        place.title = title // ✅ title 저장
        place.thumbnailURL = thumbnailURL
        place.order = order
        place.planner = planner
        planner.addToPlaces(place)

        saveContext()
        return place
    }

    func fetchPlannerPlaces(for planner: PlannerEntity) -> [PlannerPlaceEntity] {
        let request: NSFetchRequest<PlannerPlaceEntity> = PlannerPlaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "planner == %@", planner)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("fetch 실패: \(error.localizedDescription)")
            return []
        }
    }

    func updatePlannerPlace(
        _ place: PlannerPlaceEntity,
        date: Date,
        contentID: String,
        title: String, // ✅ title 추가
        thumbnailURL: String?,
        order: Int16
    ) {
        place.date = date
        place.contentID = contentID
        place.title = title // ✅ title 수정
        place.thumbnailURL = thumbnailURL
        place.order = order
        saveContext()
    }

    func deletePlannerPlace(_ place: PlannerPlaceEntity) {
        context.delete(place)
        saveContext()
    }

}
