//
//  LiveMapView.swift
//  MapPoc
//
//  Created by Ethan Van Heerden on 6/27/22.
//

import SwiftUI
import MapKit

/// Note: You can test this by mocking location with Simulator -> Features -> Location
struct LiveMapView: View {
    @StateObject private var viewModel: LiveMapViewModel = .init()
    var body: some View {
        contentView
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.sendViewEvent(.getUserLocation)
            }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .permissionDenied:
            VStack {
                Spacer()
                Text("Please enable location permissions")
                ProgressView()
                Spacer()
            }
        case .go(let stateObject):
            mapView(stateObject: stateObject)
                .onAppear {
                    viewModel.sendViewEvent(.startTracking)
                }
                .onDisappear {
                    viewModel.sendViewEvent(.endTracking)
                }
        }
    }
    
    private func mapView(stateObject: LiveMapViewStateObject) -> some View {
        return LiveMapViewUIKitWrapper(stateObject: stateObject)
    }
}

struct LiveMapView_Previews: PreviewProvider {
    static var previews: some View {
        LiveMapView()
    }
}

struct LiveMapViewUIKitWrapper: UIViewRepresentable {
    private let stateObject: LiveMapViewStateObject
    
    init(stateObject: LiveMapViewStateObject) {
        self.stateObject = stateObject
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.showsUserLocation = true
        view.region = stateObject.mapRegion
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let path = MKPolyline(coordinates: stateObject.route, count: stateObject.route.count)
        uiView.addOverlay(path)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        private let parent: LiveMapViewUIKitWrapper
        
        init(parent: LiveMapViewUIKitWrapper) {
            self.parent = parent
        }
        
        // TODO: path not working
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            /// Constructs the line line with a custom color / line size
            if let route = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: route)
                renderer.strokeColor = .blue
                renderer.lineWidth = 10
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
