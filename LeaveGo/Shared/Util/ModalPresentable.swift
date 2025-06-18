//
//  ModalPresentable.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/17/25.
//

import UIKit

protocol ModalPresentable: AnyObject {}

extension ModalPresentable where Self: UIViewController {
	func presentPlaceDetail(for place: PlaceModel) {
		PlaceActions.presentInfoModal(from: view, place: place)
	}
}
