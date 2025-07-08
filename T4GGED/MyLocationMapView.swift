// MyLocationMapView.swift
//
// A simple SwiftUI view showing the user's current location on a map using MapKit

import SwiftUI
import MapKit
import CoreLocation

struct MyLocationMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            if let userLocation = locationManager.userLocation {
                Map(position: $cameraPosition, interactionModes: .all, showsUserLocation: true)
                    .onAppear {
                        cameraPosition = .region(MKCoordinateRegion(center: userLocation, latitudinalMeters: 300, longitudinalMeters: 300))
                    }
            } else {
                ProgressView("Getting location...")
            }
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            if let coord = newLocation {
                cameraPosition = .region(MKCoordinateRegion(center: coord, latitudinalMeters: 300, longitudinalMeters: 300))
            }
        }
    }
}

// LocationManager class (copy from your HomePage.swift for reusability)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
}

#Preview {
    MyLocationMapView()
}
