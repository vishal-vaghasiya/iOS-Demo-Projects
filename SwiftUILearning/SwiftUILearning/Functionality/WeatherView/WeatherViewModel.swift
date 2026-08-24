//
//  WeatherViewModel.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 04/11/25.
//

import Foundation
import CoreLocation
import WeatherKit

@MainActor
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var locationName: String = "Current Location"

    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func loadWeather() async {
        isLoading = true
        errorMessage = nil

        do {
            let location = try await requestLocation()
            let weather = try await weatherService.weather(for: location)
            self.weather = weather
            self.locationName = await getCityName(from: location) ?? "Unknown"
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func requestLocation() async throws -> CLLocation {
        locationManager.requestWhenInUseAuthorization()
        return try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            continuation.resume(returning: locationManager.location ?? CLLocation(latitude: 37.7749, longitude: -122.4194))
        }
    }

    private func getCityName(from location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        if let placemark = try? await geocoder.reverseGeocodeLocation(location).first {
            return placemark.locality
        }
        return nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
}
