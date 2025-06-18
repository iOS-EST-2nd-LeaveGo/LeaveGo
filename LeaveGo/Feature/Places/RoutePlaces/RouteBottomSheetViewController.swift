//
//  RouteBottomSheetViewController.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/10/25.
//

import UIKit
import MapKit
import CoreLocation

protocol RouteBottomSheetViewControllerDelegate: AnyObject {
	func didTapCarButton()
	func didTapWalkButton()
	func didTapTransitButton()
	func didSelectRoute(_ route: MKRoute)
}

class RouteBottomSheetViewController: UIViewController {
	// MARK: – Properties
	private var sheetView: RouteBottomSheetView { view as! RouteBottomSheetView }
	private var tableView: UITableView { sheetView.startDestinationTableView }
	private var tableHeightConstraint: NSLayoutConstraint {
		sheetView.tableHeightConstraint
	}
	
	var destination: RouteDestination!
	
	private var selectedMode: RouteBottomSheetView.TransportMode?
	private let cellHeight: CGFloat = 45
	private let spacing:   CGFloat = 20
	
	private var stops: [Stop] = []
	// 원본 데이터
	var routesData: RouteOptions?
	// 가변 데이터 토글 - 렌더링 용
	private var displayOptions: [MKRoute] = []
	
	private var showingRoutes = false
	private var selectedIndex = 0
	
	private var connectorLayer: CAShapeLayer?
	weak var delegate: RouteBottomSheetViewControllerDelegate?
	
	func configureStops(
		currentLocationName: String = "나의 위치",
		destinationName: String
	) {
		self.stops = [
			.init(kind: .currentLocation,
				  name: currentLocationName,
				  iconName: "location.fill",
				  color: .systemBlue),
			.init(kind: .destination,
				  name: destinationName,
				  iconName: "flag.circle.fill",
				  color: .systemPink)
		]
	}
	
	// MARK: – Lifecycle
	override func loadView() {
		view = RouteBottomSheetView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupTargetActions()
		setupPassthroughArea()
		updateTableHeight()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		drawConnectorDots()
		
	}
	
	// MARK: – Setup
	
	private func setupTableView() {
		let tv = sheetView.startDestinationTableView
		tv.backgroundColor     = sheetView.backgroundColor
		tv.register(RouteStopCell.self,
					forCellReuseIdentifier: RouteStopCell.reuseIdentifier)
		
		tv.register(RouteOptionsCell.self,
					forCellReuseIdentifier: RouteOptionsCell.reuseIdentifier)
		
		tv.dataSource = self
		tv.delegate   = self
		
		tv.rowHeight       = cellHeight + spacing
		tv.isScrollEnabled = true
		tv.isEditing       = true
		tv.separatorStyle  = .singleLine
		tv.separatorColor  = .systemGray5
		tv.separatorInset  = UIEdgeInsets(
			top: 0,
			left: 0,
			bottom: 0,
			right: 0
		)
	}
	
	private func setupPassthroughArea() {
		let passthrough = RouteSheetPassthroughView()
		passthrough.backgroundColor = .clear
		passthrough.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(passthrough, at: 0)
		
		NSLayoutConstraint.activate([
			passthrough.topAnchor.constraint(equalTo: view.topAnchor),
			passthrough.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			passthrough.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			passthrough.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
	
	private func setupTargetActions() {
		sheetView.carButton.addTarget(self,
									  action: #selector(carTapped),
									  for: .touchUpInside)
		sheetView.walkButton.addTarget(self,
									   action: #selector(walkTapped),
									   for: .touchUpInside)
		
		sheetView.transitButton.addTarget(self,
										  action: #selector(transitTapped),
										  for: .touchUpInside)
		
		sheetView.select(mode: .car)
	}
	
	// MARK: – Actions
	@objc private func dismissSheet() {
		dismiss(animated: true)
	}
	
	@objc private func carTapped() {
		sheetView.select(mode: .car)
		selectedMode = .car
		
		// 항상 경로 재요청
		delegate?.didTapCarButton()
		
		// UI 갱신
		showingRoutes = true
		tableView.reloadData()
		updateTableHeight()
	}
	
	@objc private func walkTapped() {
		sheetView.select(mode: .walk)
		selectedMode = .walk
		
		delegate?.didTapWalkButton()
		
		showingRoutes = true
		tableView.reloadData()
		updateTableHeight()
	}
	
	@objc private func transitTapped() {
		routesData = nil
		displayOptions = []
		
		sheetView.select(mode: .transit)
		selectedMode = .transit
		
		// 빈 상태일 때 메시지 표시
		sheetView.emptyStateLabel.text = emptyMessage(for: .transit)
		sheetView.emptyStateLabel.isHidden = false
		
		showingRoutes = true
		
		// UI 업데이트 추가
		tableView.reloadData()
		updateTableHeight()
		
		delegate?.didTapTransitButton()
	}

	
	@objc private func navigateOptionTapped(_ sender: UIButton) {
		guard let data = routesData,
			  sender.tag < data.options.count
		else { return }
		
		let selectedRoute = data.options[sender.tag]
		delegate?.didSelectRoute(selectedRoute)
		
		guard let startCL = data.start,
			  let destCL = data.dest
		else { return }
		
		let srcPM = MKPlacemark(placemark: startCL)
		let dstPM = MKPlacemark(placemark: destCL)
		
		let srcItem = MKMapItem(placemark: srcPM)
		let dstItem = MKMapItem(placemark: dstPM)
		
		srcItem.name = startCL.name
		dstItem.name = destCL.name
		
		let directionMode: String
		switch selectedMode {
		case .car:
			directionMode = MKLaunchOptionsDirectionsModeDriving
		case .walk:
			directionMode = MKLaunchOptionsDirectionsModeWalking
		case .transit:
			directionMode = MKLaunchOptionsDirectionsModeTransit
		default:
			directionMode = MKLaunchOptionsDirectionsModeDriving
		}
		
		let launchOpts: [String: Any] = [
			MKLaunchOptionsDirectionsModeKey: directionMode
		]
		
		let alert = CustomAlertView(
			message: "애플 지도\n길 안내로 이동합니다",
			confirmTitle: "이동",
			cancelTitle: "취소",
			confirmAction: {
				MKMapItem.openMaps(with: [srcItem, dstItem], launchOptions: launchOpts)
				self.delegate?.didSelectRoute(data.options[sender.tag])
			},
			cancelAction: nil
		)
		alert.show(on: self)
	}
	
	func showRoutes(_ data: RouteOptions) {
		self.routesData = data
		self.displayOptions = data.options
		self.showingRoutes  = true
		
		if data.options.isEmpty {
			sheetView.emptyStateLabel.text = emptyMessage(for: selectedMode ?? .transit)
				sheetView.emptyStateLabel.isHidden = false
			} else {
				sheetView.emptyStateLabel.isHidden = true
			}

		tableView.reloadData()
		updateTableHeight()
	}
	
	private func emptyMessage(for mode: RouteBottomSheetView.TransportMode) -> String {
		switch mode {
		case .car:     return "자동차 경로를 사용할 수 없습니다"
		case .walk:    return "도보 경로를 사용할 수 없습니다"
		case .transit: return "대중교통 경로를 사용할 수 없습니다"
		}
	}

	
	// MARK: – Table Height
	private func updateTableHeight() {
		let stopCount = stops.count
		guard showingRoutes,
			  let opts = routesData?.options,
			  !opts.isEmpty
		else {
			tableHeightConstraint.constant = CGFloat(stopCount) * (cellHeight + spacing)
			return
		}
		
		let totalRows = stopCount + opts.count
		tableHeightConstraint.constant = CGFloat(totalRows) * (cellHeight + spacing)
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
			let indexPath = IndexPath(row: i, section: 0)
			guard let cell = sheetView.startDestinationTableView.cellForRow(at: indexPath) as? RouteStopCell else { continue }
			
			let iconCenter = cell.iconBackgroundView.center
			let iconCenterInTable = sheetView.startDestinationTableView.convert(iconCenter, from: cell.iconBackgroundView.superview)
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
		
		sheetView.startDestinationTableView.layer.addSublayer(shape)
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
			sheetView.startDestinationTableView.insertRows(
				at: [IndexPath(row: 1, section: 0)],
				with: .automatic
			)
		} else {
			stops[1] = dest
			sheetView.startDestinationTableView.reloadRows(
				at: [IndexPath(row: 1, section: 0)],
				with: .automatic
			)
		}
		updateTableHeight()
	}
}

// MARK: – UITableViewDataSource / UITableViewDelegate
extension RouteBottomSheetViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let stopCount = stops.count
		guard showingRoutes,
			  let opts = routesData?.options,
			  !opts.isEmpty else { return stopCount }
		return stopCount + opts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row < stops.count {
			let cell = tableView.dequeueReusableCell(
				withIdentifier: RouteStopCell.reuseIdentifier,
				for: indexPath
			) as! RouteStopCell
			let stop = stops[indexPath.row]
			cell.configure(
				with: stop,
				isFirst: indexPath.row == 0,
				isLast: indexPath.row == stops.count - 1
			)
			cell.selectionStyle = .none
			return cell
		}
		
		let opts = routesData!.options
		let idx  = indexPath.row - stops.count
		let routeOpt = opts[idx]
		
		let cell = tableView.dequeueReusableCell(
			withIdentifier: RouteOptionsCell.reuseIdentifier,
			for: indexPath
		) as! RouteOptionsCell
		
		cell.configure(
			with: routeOpt,
			at: idx,
			target: self,
			action: #selector(navigateOptionTapped)
		)
		cell.selectionStyle = .none
		return cell
	}
	
	
	func tableView(
		_ tableView: UITableView,
		editingStyleForRowAt indexPath: IndexPath
	) -> UITableViewCell.EditingStyle {
		.none
	}
	
	func tableView(
		_ tableView: UITableView,
		shouldIndentWhileEditingRowAt indexPath: IndexPath
	) -> Bool {
		false
	}
	
	func tableView(
		_ tableView: UITableView,
		canMoveRowAt indexPath: IndexPath
	) -> Bool {
		return indexPath.row < stops.count
	}
	
	func tableView(
		_ tableView: UITableView,
		moveRowAt sourceIndexPath: IndexPath,
		to destinationIndexPath: IndexPath
	) {
		let moved = stops.remove(at: sourceIndexPath.row)
		stops.insert(moved, at: destinationIndexPath.row)
		tableView.reloadData()
		updateTableHeight()
	}
}

extension RouteBottomSheetViewController: UITableViewDelegate {
	func tableView(
		_ tableView: UITableView,
		willSelectRowAt indexPath: IndexPath
	) -> IndexPath? {
		return indexPath.row < stops.count ? nil : indexPath
	}
	
	func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		guard let data = routesData,
			  indexPath.row >= stops.count,
			  indexPath.row < stops.count + data.options.count
		else { return }
		
		let optionIndex = indexPath.row - stops.count
		let selectedRoute = data.options[optionIndex]
		
		DispatchQueue.main.async { [weak self] in
			self?.delegate?.didSelectRoute(selectedRoute)
		}
	}
}

//MARK: - Preview Setting
#if DEBUG
import SwiftUI
import MapKit
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
