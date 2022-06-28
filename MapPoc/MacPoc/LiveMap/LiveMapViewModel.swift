//
//  LiveMapViewModel.swift
//  MapPoc
//
//  Created by Ethan Van Heerden on 6/27/22.
//

import Foundation
import SwiftUI
import MapKit

final class LiveMapViewModel: NSObject, ObservableObject {
    @Published private(set) var viewState: LiveMapViewState = .permissionDenied
    private var locationManager: CLLocationManager? /// Probably want to extract this into our own interactor protocol
    
    func sendViewEvent(_ event: LiveMapViewEvent) {
        switch event {
        case .getUserLocation:
            handleGetUserLocation()
        case .startTracking:
            handleStartTracking()
        case .endTracking:
            return
        }
    }
}

// MARK: - Private

private extension LiveMapViewModel {
    func handleGetUserLocation() {
        /// We first need to check if the user has device-wide location services enabled
        guard CLLocationManager.locationServicesEnabled() else {
            /// Could update something in the view state here to show a dialog to tell the user to enable location services
            return
        }
        
        locationManager = CLLocationManager()
        locationManager?.activityType = .fitness
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        /// We then need to check that the user has location permissions on for this app through the delegate (so we know whenever they change permissions)
        locationManager?.delegate = self
    }
    
    func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            /// Ask for permission
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            /// Parental controls / they rejected permissions
            /// Could do some additional error handling here
            return
        case .authorizedAlways, .authorizedWhenInUse:
            /// Update the view state!
            Task {
                await MainActor.run {
                    let region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
                                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    let stateObject = LiveMapViewStateObject(mapRegion: region, route: [])
                    viewState = .go(stateObject)
                }
            }
        @unknown default:
            return
        }
    }
    
    func handleStartTracking() {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.startUpdatingLocation()
        // locationManager.allowsBackgroundLocationUpdates = true -> Need to change PList or fatal error
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func handleEndTracking() {
        guard let locationManager = locationManager else {
            return
        }
        locationManager.stopUpdatingLocation()
        locationManager.showsBackgroundLocationIndicator = false
    }
}

// MARK: - CLLocationManagerDelegate

extension LiveMapViewModel: CLLocationManagerDelegate {
    /// Allows us to appropriately update view state if the user disables locations midrun
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard case .go(let stateObject) = viewState else {
            return
        }
        Task(priority: .userInitiated) {
            await MainActor.run {
                /// Update the user's travelled route so we can draw it
                var newCoordinates = stateObject.route
                newCoordinates.append(contentsOf: locations.map { $0.coordinate} )

                let newStateObject = LiveMapViewStateObject(mapRegion: stateObject.mapRegion,
                                                            route: newCoordinates)
                viewState = .go(newStateObject)
            }
        }
    }
}

// MARK: View Events

enum LiveMapViewEvent {
    case getUserLocation
    case startTracking
    case endTracking
}
