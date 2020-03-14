//
//  MapView.swift
//  MapboxApp
//
//  Created by Tu Dat Nguyen on 2019-12-30.
//  Copyright © 2019 Tu Dat Nguyen. All rights reserved.
//

import SwiftUI
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

extension MGLPointAnnotation {
    convenience init(title: String, coordinate: CLLocationCoordinate2D) {
        self.init()
        self.title = title
        self.coordinate = coordinate
    }
}

// create MapViewController to represent the MapView
struct MapView: UIViewRepresentable {
    private let mapView: NavigationMapView = NavigationMapView(frame: .zero, styleURL: MGLStyle.streetsStyleURL)
        
    @Binding var annotations: [MGLPointAnnotation]
    @Binding var directionsRoute: Route?
    @Binding var showNavigation: Bool
        
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MGLMapView {
        /* https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable */
        mapView.delegate = context.coordinator
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: UIViewRepresentableContext<MapView>) {
        updateAnnotations()
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    private func updateAnnotations() {
        if let currentAnnotations = mapView.annotations {
            mapView.removeAnnotations(currentAnnotations)
        }
        mapView.addAnnotations(annotations)
    }
    
    func styleURL(_ styleURL: URL) -> MapView {
        mapView.styleURL = styleURL
        return self
    }
    
    func centerCoordinate(_ centerCoordinate: CLLocationCoordinate2D) -> MapView {
        mapView.centerCoordinate = centerCoordinate
        return self
    }
    
    func zoomLevel(_ zoomLevel: Double) -> MapView {
        mapView.zoomLevel = zoomLevel
        return self
    }
    
    // this delegate actions can be done for the mapView
    /* https://docs.mapbox.com/ios/api/maps/5.7.0/Protocols/MGLMapViewDelegate.html */
    
    class Coordinator: NSObject, MGLMapViewDelegate {
        var control: MapView
                
        private var directionsRoute: Route?
        
        init(_ control: MapView) {
            self.control = control
        }
        
        @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
            guard sender.state == .began else { return }
            let mapView = control.mapView
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MGLPointAnnotation(title: "Start navigation", coordinate: coordinate)
            mapView.addAnnotation(annotation)
            
            // Calculate the route from the user's location to the set destination
            calculateRoute(from: (mapView.userLocation!.coordinate), to: annotation.coordinate) { (route, error) in
                if error != nil {
                    print("Error calculating route")
                }
            }
        }
        
        func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: false, completionHandler: nil)
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
            mapView.addGestureRecognizer(longPress)
        }
        
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            return nil
        }
        
        func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
            return true
        }
        
        func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
            moveToCoordinate(mapView, to: annotation.coordinate)
        }
        
        func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
            self.control.directionsRoute = directionsRoute
            self.control.showNavigation = true
        }
        
        // convenient method to move the camera to a point
        private func moveToCoordinate(_ mapView: MGLMapView, to point: CLLocationCoordinate2D) {
            let currentCamera = mapView.camera
            let camera = MGLMapCamera(lookingAtCenter: point, acrossDistance: currentCamera.viewingDistance, pitch: currentCamera.pitch, heading: currentCamera.heading)
            mapView.fly(to: camera, withDuration: 4, peakAltitude: 3000, completionHandler: nil)
        }
        
        func drawRoute(_ mapView: MGLMapView, route: Route) {
            guard route.coordinateCount > 0 else { return }
            // Convert the route’s coordinates into a polyline
            var routeCoordinates = route.coordinates!
            let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
            
            // If there's already a route line on the map, reset its shape to the new route
            if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
                source.shape = polyline
            } else {
                let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
                
                // Customize the route line color and width
                let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
                lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
                lineStyle.lineWidth = NSExpression(forConstantValue: 3)
                
                // Add the source and style layer of the route line to the map
                mapView.style?.addSource(source)
                mapView.style?.addLayer(lineStyle)
            }
        }
        
        func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> ()) {
            let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
            let mapView = control.mapView
            let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
            // specify the route
            let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .cycling)
            // generate the route
            // Generate the route object and draw it on the map
            _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
                self.directionsRoute = routes?.first
                // Draw the route on the map after creating it
                self.drawRoute(mapView, route: self.directionsRoute!)
            }
        }
    }
}


