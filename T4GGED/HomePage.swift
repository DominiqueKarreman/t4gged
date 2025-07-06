//
//  ContentView.swift
//  T4GGED
//
//  Created by Dominique Karreman on 6/15/25.
//

import SwiftUI
import CoreData
import MapKit
import UIKit
import CoreLocation
import Combine

struct CustomMapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D?
    var span: MKCoordinateSpan

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        if let coordinate = coordinate {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
        mapView.overrideUserInterfaceStyle = .dark
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let coordinate = coordinate {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            // Default: nothing
            return MKOverlayRenderer()
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            return nil
        }
        func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {}
        // This is where you'd implement custom overlays if needed
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}

struct HomePage: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var locationManager = LocationManager()
    @State private var showFullMap = false
    @Namespace private var mapNamespace
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Handle menu action
                }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.white)
                        .font(.title)
                }
                Spacer()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                Spacer()
                Button(action: {
                    // Handle profile action
                }) {
                    Image(systemName: "person.circle")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
            .padding(.horizontal)
            .padding(.top, 32)
            
            ZStack {
                // Small map widget
                ZStack(alignment: .bottomLeading) {
                    CustomMapView(
                        coordinate: locationManager.location?.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08) // Extra tight zoom
                    )
                    .matchedGeometryEffect(id: "mapWidget", in: mapNamespace)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(height: 220)
                    .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.95), Color.clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Live map")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text("track the people you need to tag!")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.76))
                            .fontWeight(.regular)
                    }
                    .padding([.bottom, .leading], 30)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .opacity(showFullMap ? 0 : 1)
                .allowsHitTesting(!showFullMap)
                
                if showFullMap {
                    FullMapScreen(
                        coordinate: locationManager.location?.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08),
                        mapNamespace: mapNamespace,
                        onClose: {
                            showFullMap = false
                        }
                    )
                    .transition(.identity)
                    .opacity(showFullMap ? 1 : 0)
                    .allowsHitTesting(showFullMap)
                }
                
                if !showFullMap {
                    // Transparent button overlay to trigger full map
                    Button(action: {
                        showFullMap = true
                    }) {
                        Color.clear
                    }
                    .frame(height: 220)
                    .padding(.horizontal)
                    .padding(.top, 24)
                }
            }
            .animation(.spring(), value: showFullMap)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
}

#Preview {
    HomePage().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

struct FullMapScreen: View {
    var coordinate: CLLocationCoordinate2D?
    var span: MKCoordinateSpan
    var mapNamespace: Namespace.ID
    var onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            CustomMapView(coordinate: coordinate, span: span)
                .matchedGeometryEffect(id: "mapWidget", in: mapNamespace)
                .ignoresSafeArea()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 2)
            }
            .padding(.top, 24)
            .padding(.trailing, 18)
        }
    }
}
