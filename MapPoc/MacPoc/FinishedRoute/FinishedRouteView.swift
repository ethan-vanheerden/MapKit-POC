//
//  MapWithPath.swift
//  MapPoc
//
//  Created by Ethan Van Heerden on 6/27/22.
//

import SwiftUI
import MapKit

struct FinishedRouteView: View {
    /// This tells the map where we should start and how zoomed in we are
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.361145, longitude: -71.057083),
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    /// The list of coordinates (from start to end) of the route we traveled
    private let coordinatePath = [
    CLLocationCoordinate2D(latitude: 42.361145, longitude: -71.057083),
    CLLocationCoordinate2D(latitude: 42.361155, longitude: -71.057083),
    CLLocationCoordinate2D(latitude: 42.361165, longitude: -71.057083),
    CLLocationCoordinate2D(latitude: 42.361175, longitude: -71.057083),
    CLLocationCoordinate2D(latitude: 42.361185, longitude: -71.057083),
    CLLocationCoordinate2D(latitude: 42.361195, longitude: -71.057083),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.057183),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.057283),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.057383),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.057483),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.057583),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.057683),
    CLLocationCoordinate2D(latitude: 42.361215, longitude: -71.067783)
    ]
    
    var body: some View {
        /// We need to use a UIViewRepresentable here since the newer Map does not support adding a static path to it yet
        FinishedRouteViewUIKitWrapper(region: region, coordinatePath: coordinatePath)
            .preferredColorScheme(.dark) /// dark/light color scheme
            .edgesIgnoringSafeArea(.all) /// takes up entire screen if it's the whole view
    }
}

struct MapWithPath_Previews: PreviewProvider {
    static var previews: some View {
        FinishedRouteView()
    }
}

struct FinishedRouteViewUIKitWrapper: UIViewRepresentable {
    private let region: MKCoordinateRegion
    private let coordinatePath: [CLLocationCoordinate2D]
    
    init(region: MKCoordinateRegion, coordinatePath: [CLLocationCoordinate2D]) {
        self.region = region
        self.coordinatePath = coordinatePath
    }
    
    func makeUIView(context: Context) -> MKMapView {
        /// This will be the parent view component
        let view = MKMapView()
        view.region = region
        view.delegate = context.coordinator
        
        /// Creates the route which we will be displaying
        let path = MKPolyline(coordinates: coordinatePath, count: coordinatePath.count)
        view.addOverlay(path) /// Will call `rendererFor` in delegate
        
        /// Add Start and End pins
        let startPin = CustomAnnotation(coordinate: coordinatePath.first!, pinType: .start)
        let endPin = CustomAnnotation(coordinate: coordinatePath.last!, pinType: .end)
        view.addAnnotations([startPin, endPin]) /// Will call `viewFor annotation` in delegate for the specific view to draw
        
        view.isUserInteractionEnabled = true /// Allows user interaction with the map (pinching, scrolling, etc.)
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    // MARK: - Coordinator
    
    /// Acts as the delegate for MKMapKit
    class Coordinator: NSObject, MKMapViewDelegate {
        private let parent: FinishedRouteViewUIKitWrapper
        
        init(parent: FinishedRouteViewUIKitWrapper) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            /// Constructs the line line with a custom color / line size
            if let route = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: route)
                renderer.strokeColor = .systemPink
                renderer.lineWidth = 10
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? CustomAnnotation else {
                return nil
            }
            
            let image = annotation.pinType.image
            /// Need to deque an AnnotationView for MapKit optimization purposes
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
            
            if annotationView == nil {
                /// If this is nil, this is the first time we are constructing the view, so we create it from scratch here
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
                annotationView?.image = image
            } else {
                /// Otherwise we can simply set its annotation
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}

final class CustomAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let pinType: MapPinType
    
    init(coordinate: CLLocationCoordinate2D, pinType: MapPinType) {
        self.coordinate = coordinate
        self.pinType = pinType
    }
}

enum MapPinType {
    case start
    case end
    
    var image: UIImage? {
        switch self {
        case .start:
            return UIImage(named: "StartRoute")
        case .end:
            return UIImage(named: "EndRoute")
        }
    }
}
