//
//  ContentView.swift
//  Shared
//
//  Created by Ethan Van Heerden on 6/27/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List(AppScreen.allCases, id: \.self) { screen in
                NavigationLink {
                    AppScreenView(viewType: screen)
                } label: {
                    Text(screen.rawValue)
                }
            }
            .navigationTitle("Maps")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
