//
//  RouteBottomSheetViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

class RouteBottomSheetViewController: UIViewController {
	
	private var sheetView: RouteBottomSheetView { view as! RouteBottomSheetView }
	
	private var stops: [Stop] = [
		.init(
			kind: .currentLocation,
			name: "나의 위치",
			iconName: "location.fill",
			color: .systemBlue
		)
	]
	
	override func loadView() {
		view = RouteBottomSheetView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 테이블 뷰 세팅
		sheetView.tableView.dataSource = self
		sheetView.tableView.delegate   = self
		
		// Transport 버튼 액션 연결
		sheetView.addTransportTarget(self,
									 action: #selector(transportTapped(_:)),
									 for: .touchUpInside)
		sheetView.select(mode: .car)
		
		// 초기 테이블 높이
		updateTableHeight()
	}
	
	@objc private func transportTapped(_ btn: UIButton) {
		guard let m = RouteBottomSheetView.TransportMode(rawValue: btn.tag) else { return }
		sheetView.select(mode: m)
		// TODO: mode 변경에 따른 로직 (경로 재검색 등)
	}
	
	// MARK: – 외부(UISearchController 등)에서 호출
	func didSelectPlace(name: String, iconName: String, tintColor: UIColor) {
		let dest = Stop(kind: .destination,
						name: name,
						iconName: iconName,
						color: tintColor)
		
		if stops.count == 1 {
			stops.append(dest)
			sheetView.tableView.insertRows(at: [.init(row: 1, section: 0)],
										   with: .automatic)
		} else {
			stops[1] = dest
			sheetView.tableView.reloadRows(at: [.init(row: 1, section: 0)],
										   with: .automatic)
		}
		updateTableHeight()
	}
	
	// MARK: – 테이블 높이 갱신
	private func updateTableHeight() {
		let rowH: CGFloat = 56
		sheetView.tableHeightConstraint.constant = rowH * CGFloat(stops.count)
		// 애니메이션:
		UIView.animate(withDuration: 0.25) {
			self.sheetView.layoutIfNeeded()
		}
	}
	
}

extension RouteBottomSheetViewController: UITableViewDataSource {
	func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
		stops.count
	}
	func tableView(_ tv: UITableView,
				   cellForRowAt idx: IndexPath) -> UITableViewCell {
		let cell = tv.dequeueReusableCell(
			withIdentifier: RouteStopCell.reuseIdentifier,
			for: idx
		) as! RouteStopCell
		
		let stop = stops[idx.row]
		let isFirst = idx.row == 0
		let isLast  = idx.row == stops.count - 1
		cell.configure(with: stop, isFirst: isFirst, isLast: isLast)
		return cell
	}
	
	// 이동 컨트롤 허용(지금은 고정 비허용)
	func tableView(_ tv: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	func tableView(_ tv: UITableView,
				   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		.none
	}
}

extension RouteBottomSheetViewController: UITableViewDelegate {
	func tableView(_ tv: UITableView,
				   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		false
	}
}
