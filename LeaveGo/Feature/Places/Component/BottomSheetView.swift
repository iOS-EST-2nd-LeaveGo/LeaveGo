//
//  BottomSheetView.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/10/25.
//

import MapKit
import UIKit

final class BottomSheetView: PassThroughView {
    
    // MARK: Constants
    enum Mode {
        case tip
        case full
    }
    
    private enum Const {
        static let duration = 0.5
        static let cornerRadius = 10 // 37.0
        static let barViewTopSpacing = 5.0
        static let barViewSize = CGSize(width: UIScreen.main.bounds.width * 0.1, height: 5.0)
        static let bottomSheetRatio: (Mode) -> Double = { mode in
            switch mode {
            case .tip:
                return 0.77 // 값 작을수록 sheetview 높이 커짐
            case .full:
                return 0.65
            }
        }
        static let bottomSheetYPosition: (Mode) -> Double = { mode in
            Self.bottomSheetRatio(mode) * UIScreen.main.bounds.height
        }
    }
    
    // MARK: Properties
    /// Mode(확장)상태에 따라 실행될 로직들
    var mode: Mode = .tip {
        didSet {
            switch self.mode {
            case .tip:
                mapView?.deselectAnnotation(mapView?.selectedAnnotations as? MKAnnotation, animated: true)
                // TODO: mapView.removeMapViewOverlayOfLast()
                // TODO: self.changeModeToTip()
                break
            case .full:
                // TODO: self.changeModeToFull()
                break
            }
            // TODO: self.updateConstraint(offset: Const.bottomSheetYPosition(self.mode))
        }
    }
    var bottomSheetColor: UIColor? {
        didSet { self.bottomSheetView.backgroundColor = self.bottomSheetColor }
    }
    var barViewColor: UIColor? {
        didSet { self.barView.backgroundColor = self.barViewColor }
    }
    var customOrangeColor: UIColor = UIColor(cgColor: CGColor(red: 243/255, green: 166/255, blue: 88/255, alpha: 1))
    // TODO: identi color정해지면 바꾸기
    var mapView: MKMapView!
    //    weak var delegate: BottomSheetViewDelegate?
    var selectedPinModel: PlaceAnnotationModel?
    static let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    var distanceOfMeters: Double = 0.0 {
        didSet {
            self.distanceLabel.text = "\(distanceOfMeters)"
        }
    }
    
    // MARK: UI
    lazy var boundaryLineView: UIView = {
        let view = UIView()
        view.backgroundColor = customOrangeColor
        return view
    }()
    let bottomSheetView: UIView = {
        let view = UIView()
        return view
    }()
    private let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 2.5
        return view
    }()
    let handlerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // stateContainView
    let stateContainView: UIView = {
        let view = UIView()
        return view
    }()
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "94"
        //"\(self.distanceOfMeters)"
        label.font = UIFont(name: "Inter-Bold", size: 15)
        label.textColor = .gray//UIColor(cgColor: CGColor(red: 147, green: 145, blue: 145, alpha: 1))
        return label
    }()
    
    
    
}
