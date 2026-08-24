//
//  LocationManager.swift
//  GoogleRoutDirections
//
//  Created by Nexios02 on 23/08/23.
//  Copyright © 2023 vishal. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        configureLocationManager()
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        sendLocationToAPI(location: location)
    }
    
    func sendLocationToAPI(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let parameters: [String: Any] = ["latitude": latitude, "longitude": longitude]
        
        AF.request("https://your-api-url.com/update-location", method: .post, parameters: parameters)
            .response { response in
                print("Location update sent to API")
            }
    }
}
