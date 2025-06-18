//
//  PlaceAnnotationModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/10/25.
//

import MapKit

class PlaceAnnotationModel: NSObject, MKAnnotation {
	// 원본 PlaceModel 보관
	let placeModel: PlaceModel
	
	// MKAnnotation 필수 프로퍼티
	let coordinate: CLLocationCoordinate2D
	let title: String?
	
	// 기타 필요한 정보
	let thumbnailImage: UIImage?
	let areaCode, cat1, cat2, cat3: String?
	let contentId, contentTypeId: String
	
	// PlaceModel 하나로부터 초기화
	init(place: PlaceModel) {
		self.placeModel     = place
		self.coordinate     = CLLocationCoordinate2D(
			latitude: place.latitude,
			longitude: place.longitude
		)
		self.title          = place.title
		self.thumbnailImage = place.thumbnailImage
		self.areaCode       = place.areaCode
		self.cat1           = place.cat1
		self.cat2           = place.cat2
		self.cat3           = place.cat3
		self.contentId      = place.contentId
		self.contentTypeId  = place.contentTypeId
	}
}
