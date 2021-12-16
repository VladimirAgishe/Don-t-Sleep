//
//  Location.swift
//  DontSleep
//
//  Created by Vladimir Agishev on 11.11.2021.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject{
    
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    override init(){
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.stopMonitoringSignificantLocationChanges()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.stopMonitoringSignificantLocationChanges()
        
    }
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        guard let location = locations.last else {
            return self.location = location
            
        }
        self.location = location
        
    }
}
