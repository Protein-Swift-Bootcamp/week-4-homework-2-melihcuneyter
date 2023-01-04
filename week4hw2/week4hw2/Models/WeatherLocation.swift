//
//  WeatherLocation.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
