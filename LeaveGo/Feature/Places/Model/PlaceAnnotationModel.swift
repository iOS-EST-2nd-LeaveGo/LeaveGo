//
//  PlaceAnnotationModel.swift
//  LeaveGo
//
//  Created by 이치훈 on 6/10/25.
//

import MapKit
import Foundation

class PlaceAnnotationModel {
  var pinID: String
   var address = ""
  let title: String = ""
   var latitude: Double = 0.0
   var longitude: Double = 0.0
   var elevation: Double = 60.0
   var distance: Int = 0
   
   init(address: String = "", latitude: Double, longitude: Double) {
     self.address = address
     self.latitude = latitude
     self.longitude = longitude
     self.pinID = "\(latitude)" + "\(longitude)"
   }
   
   func setDistance(_ dis: Int) {
     self.distance = dis
   }
   
}
