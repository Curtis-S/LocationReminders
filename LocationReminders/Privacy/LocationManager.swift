//
//  LocationManager.swift
//  LocationReminders
//
//  Created by curtis scott on 12/09/2019.
//  Copyright © 2019 CurtisScott. All rights reserved.
//

import Foundation

import UIKit
import MapKit

class LocationManager:NSObject {
    
      let locationManager = CLLocationManager()
      var mapView: MKMapView?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
      
        
    }
    
    
    func requestStuff()  {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    
//    func region(with geotification: GeoNotifacation) -> CLCircularRegion {
//        // 1
//        let region = CLCircularRegion(center: geotification.coordinate,
//                                      radius: geotification.radius,
//                                      identifier: geotification.identifier)
//        // 2
//        region.notifyOnEntry = (geotification.eventType == .onEntry)
//        region.notifyOnExit = !region.notifyOnEntry
//        return region
//    }
}


extension LocationManager : CLLocationManagerDelegate {
    
   
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
        }
        
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView!.setRegion(region, animated: true)
        }
        
    }
    
   
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("error:: \(error)")
    }
}
