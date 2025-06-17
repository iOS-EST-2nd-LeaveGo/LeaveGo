//
//  UIViewController+RouteHelper.swift
//  LeaveGo
//
//  Created by Seohyun Kim on 6/18/25.
//
import UIKit
import MapKit

/// UIViewController + RouteHelper
///  - 목적지 데이터를 가지고 경로 찾는 화면으로 이동할 수 있게 구현한 헬퍼 함수입니다.
extension UIViewController {
	func showRouteScreen(
		destination: RouteDestination,
		animated: Bool = true
	) {
		// 1) PlaceRouteVC 인스턴스화
		let sb = UIStoryboard(name: "PlaceRoute", bundle: nil)
		guard let routeVC = sb.instantiateViewController(identifier: "PlaceRoute")
				as? PlaceRouteViewController else {
			print("'PlaceRoute' 스토리보드 ID 확인 필요")
			return
		}
		routeVC.destination = destination
		
		// 2) 푸시할 네비게이션 컨트롤러 찾기
		let hostNav: UINavigationController? = {
			// # CASE 1. 현재 VC가 네비게이션 안에 있는 경우
			if let nav = self.navigationController { return nav }
			
			// # CASE 2. present한 VC(presenter)가 네비게이션 안에 있는 경우
			if let presNav = self.presentingViewController?.navigationController {
				return presNav
			}
			
			// # CASE 3. presenter가 TabBarController 라면, 그 선택된 VC가 네비일수도 있음
			if let tab = self.presentingViewController as? UITabBarController,
			   let selectNav = tab.selectedViewController as? UINavigationController {
				return selectNav
			}
			
			// # CASE 4. 혹은 self 인스턴스가 TabBarController 안에서 호출된 경우
			if let tab = self as? UITabBarController,
			   let selNav = tab.selectedViewController as? UINavigationController {
				return selNav
			}
			
			return nil
		}()
		
		// 3) 찾아서 푸시
		if let nav = hostNav {
			nav.pushViewController(routeVC, animated: animated)
		} else {
			assertionFailure("showRouteScreen: 푸시할 네비게이션 컨트롤러가 없습니다.")
		}
	}
}
