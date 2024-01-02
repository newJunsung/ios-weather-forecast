//
//  WeatherLocationManager.swift
//  WeatherForecast
//
//  Created by Wonji Ha on 2023/11/24.
//

import Foundation
import CoreLocation

final class WeatherLocationManager: NSObject {
    private let locationManger: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()
    
    weak var delegate: WeatherUIDelegate?
    
    override init() {
        super.init()
        locationManger.delegate = self
    }

    func requestLocation() {
        locationManger.requestLocation()
    }
    
    func getAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "ko-kR")
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), preferredLocale: locale, completionHandler: { placemarks, error in
            guard let placemark = placemarks?.last, error == nil else {
                return
            }
            var address = ""
            if let country = placemark.country { address += "\(country) " }
            if let subAdministrativeArea = placemark.subAdministrativeArea { address += "\(subAdministrativeArea) " }
            if let administrativeArea = placemark.administrativeArea { address += "\(administrativeArea) " }
            if let subThoroughfare = placemark.name { address += "\(subThoroughfare) " }
            DispatchQueue.main.async {
                self.delegate?.updateLocationWeather(coordinate, address)
            }
        })
    }	
}

extension WeatherLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            getAddress(from: location.coordinate)
            locationManger.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("위치 업데이트 실패: ", error.localizedDescription)
    }
}
