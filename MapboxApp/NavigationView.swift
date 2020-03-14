//
//  NavigationView.swift
//  MapboxApp
//
//  Created by Tu Dat Nguyen on 2020-01-01.
//  Copyright © 2020 Tu Dat Nguyen. All rights reserved.
//

import SwiftUI
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

struct NavigationView: UIViewControllerRepresentable {
    func makeCoordinator() -> NavigationView.Coordinator {
        Coordinator(self)
    }
    
    
    @Binding var directionsRoute: Route?
    @Binding var showNavigation: Bool
            
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationView>) -> NavigationViewController {
        let navigationViewController = NavigationViewController(for: directionsRoute!)
        navigationViewController.delegate = context.coordinator
        return navigationViewController
    }
    
    func updateUIViewController(_ uiViewController: NavigationViewController, context: UIViewControllerRepresentableContext<NavigationView>) {
        // do nothing
    }
    
    class Coordinator: NSObject, NavigationViewControllerDelegate {
        var control: NavigationView
        
        init(_ control: NavigationView) {
            self.control = control
        }
        
        func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
            self.control.showNavigation = false
        }
    }
}
