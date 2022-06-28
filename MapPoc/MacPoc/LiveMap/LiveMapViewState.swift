//
//  LiveMapViewState.swift
//  MapPoc
//
//  Created by Ethan Van Heerden on 6/27/22.
//

import Foundation
import MapKit

enum LiveMapViewState {
    case permissionDenied
    case go(LiveMapViewStateObject)
}

struct LiveMapViewStateObject {
    let mapRegion: MKCoordinateRegion
    let route: [CLLocationCoordinate2D]
}
