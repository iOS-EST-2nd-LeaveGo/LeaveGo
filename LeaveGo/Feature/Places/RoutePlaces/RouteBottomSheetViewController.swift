//
//  RouteBottomSheetViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit

protocol RouteBottomSheetViewControllerDelegate: AnyObject {
	func didTapCarButton()
}

class RouteBottomSheetViewController: UIViewController {
	// MARK: – Properties

	private var sheetView: RouteBottomSheetView { view as! RouteBottomSheetView }

	private let cellHeight: CGFloat = 45
	private let spacing:   CGFloat = 20

	private var stops: [Stop] = [
		.init(kind: .currentLocation,
			  name: "나의 위치",
			  iconName: "location.fill",
			  color: .systemBlue),
		.init(kind: .destination,
			  name: "롯데월드",
			  iconName: "flag.circle.fill",
			  color: .systemPink)
	]

	private var connectorLayer: CAShapeLayer?
	weak var delegate: RouteBottomSheetViewControllerDelegate?

	// MARK: – Lifecycle
	override func loadView() {
		view = RouteBottomSheetView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupButtons()
		updateTableHeight()
		sheetView.tableView.reloadData()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		drawConnectorDots()
	}

	// MARK: – Setup
	private func setupTableView() {
		let tv = sheetView.tableView
		tv.register(RouteStopCell.self,
					forCellReuseIdentifier: RouteStopCell.reuseIdentifier)
		tv.dataSource = self
		tv.delegate   = self

		tv.rowHeight       = cellHeight + spacing
		tv.isScrollEnabled = true 
		tv.isEditing       = true
		tv.separatorStyle  = .singleLine
		tv.separatorColor  = .systemGray5
		tv.separatorInset  = UIEdgeInsets(
			top: 0,
			left: 76,
			bottom: 0,
			right: 32
		)
	}
	
	private func setupButtons() {
//		sheetView.closeButton.addTarget(self,
//										action: #selector(dismissSheet),
//										for: .touchUpInside)
		sheetView.carButton.addTarget(self,
									  action: #selector(carTapped),
									  for: .touchUpInside)
		sheetView.walkButton.addTarget(self,
									   action: #selector(walkTapped),
									   for: .touchUpInside)
									 
		sheetView.select(mode: .car)
		
	}

	// MARK: – Actions
	@objc private func dismissSheet() {
		dismiss(animated: true)
	}
	
	@objc private func carTapped() {
		sheetView.select(mode: .car)
		print("tapped car button")
		delegate?.didTapCarButton()
	}
	
	@objc private func walkTapped() {
		sheetView.select(mode: .walk)
		print("tapped walk button")
	}
	

	// MARK: – Table Height
	private func updateTableHeight() {
		let total = CGFloat(stops.count) * (cellHeight + spacing)
		sheetView.tableHeightConstraint.constant = total
		view.layoutIfNeeded()
	}
	
	private func drawConnectorDots() {
		connectorLayer?.removeFromSuperlayer()
		guard stops.count >= 2 else { return }

		let shape = CAShapeLayer()
		shape.strokeColor     = UIColor.systemGray.cgColor
		shape.fillColor       = nil
		shape.lineWidth       = 3
		shape.lineDashPattern = [0, 8]
		shape.lineCap         = .round
		shape.zPosition       = 10

		let path = UIBezierPath()

		var iconCenters: [CGPoint] = []

		for i in 0..<stops.count {
			let ip = IndexPath(row: i, section: 0)
			guard let cell = sheetView.tableView.cellForRow(at: ip) as? RouteStopCell else { continue }

			let iconCenter = cell.iconBackgroundView.center
			let iconCenterInTable = sheetView.tableView.convert(iconCenter, from: cell.iconBackgroundView.superview)
			iconCenters.append(iconCenterInTable)
		}

		if iconCenters.count >= 2 {
			let iconRadius: CGFloat = 20
			let first = iconCenters.first!
			let last = iconCenters.last!

			let dy = last.y - first.y
			let dx = last.x - first.x
			let length = sqrt(dx*dx + dy*dy)

			let ux = dx / length
			let uy = dy / length

			let adjustedStart = CGPoint(x: first.x + ux * iconRadius, y: first.y + uy * iconRadius)
			let adjustedEnd   = CGPoint(x: last.x - ux * iconRadius, y: last.y - uy * iconRadius)

			path.move(to: adjustedStart)
			path.addLine(to: adjustedEnd)
		}

		shape.path = path.cgPath

		sheetView.tableView.layer.addSublayer(shape)
		connectorLayer = shape
	}

	func didSelectPlace(name: String,
						iconName: String,
						tintColor: UIColor) {
		let dest = Stop(kind: .destination,
						name: name,
						iconName: iconName,
						color: tintColor)

		if stops.count == 1 {
			stops.append(dest)
			sheetView.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
		} else {
			stops[1] = dest
			sheetView.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
		}
		updateTableHeight()
	}
}

// MARK: – UITableViewDataSource / UITableViewDelegate

extension RouteBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
		stops.count
	}

	func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tv.dequeueReusableCell(
			withIdentifier: RouteStopCell.reuseIdentifier,
			for: indexPath
		) as! RouteStopCell
		
		let stop = stops[indexPath.row]
		
		let isFirst = indexPath.row == 0
		let isLast  = indexPath.row == stops.count - 1
		cell.configure(with: stop, isFirst: isFirst, isLast: isLast)
		
		return cell
	}

	func tableView(_ tv: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		.none
	}
	func tableView(_ tv: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		false
	}
	func tableView(_ tv: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		true
	}
	func tableView(_ tv: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let moved = stops.remove(at: sourceIndexPath.row)
		stops.insert(moved, at: destinationIndexPath.row)
		tv.reloadData()
		updateTableHeight()
	}
}

//MARK: - Preview Setting

#if DEBUG
import SwiftUI
struct Preview: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> some UIViewController {
		RouteBottomSheetViewController()
	}
	
	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		
	}
}

struct RouteBottomSheetViewController_Preview: PreviewProvider {
	static var previews: some View {
		Group {
			Preview()
		}
	}
}
#endif
