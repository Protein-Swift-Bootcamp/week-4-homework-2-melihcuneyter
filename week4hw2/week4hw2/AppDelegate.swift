//
//  AppDelegate.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 1.01.2023.
//

import UIKit
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSPlacesClient.provideAPIKey(Keys.googlePlacesKey)
        
        return true
    }
}

