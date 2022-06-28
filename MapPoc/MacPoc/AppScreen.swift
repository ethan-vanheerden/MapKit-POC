//
//  AppScreen.swift
//  MapPoc
//
//  Created by Ethan Van Heerden on 6/27/22.
//

import Foundation
import SwiftUI

enum AppScreen: String, CaseIterable {
    case finishedRoute = "Finished Route"
    case liveMap = "Live Map"
}

struct AppScreenView: View {
    private let viewType: AppScreen
    
    init(viewType: AppScreen) {
        self.viewType = viewType
    }
    
    var body: some View {
        switch viewType {
        case .finishedRoute:
            FinishedRouteView()
        case .liveMap:
            LiveMapView()
        }
    }
}
