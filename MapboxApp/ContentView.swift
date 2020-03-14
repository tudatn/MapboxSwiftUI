//
//  ContentView.swift
//  MapboxApp
//
//  Created by Tu Dat Nguyen on 2019-12-30.
//  Copyright © 2019 Tu Dat Nguyen. All rights reserved.
//

import SwiftUI
import Mapbox
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

struct ContentView: View {
    @State var annotations: [MGLPointAnnotation] = [
        MGLPointAnnotation(title: "Mapbox", coordinate: .init(latitude: 37.791434, longitude: -122.396267))
    ]
    
    @State var directionsRoute: Route?
    
    @State var showNavigation = false
    
    var body: some View {
        MapView(annotations: $annotations, directionsRoute: $directionsRoute, showNavigation: $showNavigation).centerCoordinate(.init(latitude: 37.791293, longitude: -122.396324)).zoomLevel(16.0).styleURL(MGLStyle.streetsStyleURL).sheet(isPresented: $showNavigation, content: {NavigationView(directionsRoute: self.$directionsRoute, showNavigation: self.$showNavigation)})
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
