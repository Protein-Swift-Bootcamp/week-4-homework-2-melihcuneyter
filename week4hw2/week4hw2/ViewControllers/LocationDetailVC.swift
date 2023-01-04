//
//  LocationDetailVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import UIKit

class LocationDetailVC: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationTempLabel: UILabel!
    @IBOutlet weak var locationSummaryLabel: UILabel!
    @IBOutlet weak var locationMinMaxTempLabel: UILabel!
    
    var weatherLocation: WeatherLocation!
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if weatherLocation == nil {
            weatherLocation = WeatherLocation(name: "Current Location", latitude: 0, longitude: 0)
            weatherLocations.append(weatherLocation)
        }
        
        loadLocations()
        clearData()
    }
    
    private func clearData() {
        locationNameLabel.text = weatherLocation.name
        locationTempLabel.text = "--°"
        locationSummaryLabel.text = ""
        locationMinMaxTempLabel.text = ""
    }
    
    private func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            weatherLocations.append(WeatherLocation(name: "Current Location", latitude: 40.98, longitude: 29.03))
            return
        }
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherLocation] {
            self.weatherLocations = weatherLocations
        } else {
            print("Error: Couldn't decode data read from UserDefaults.")
        }
        
        if weatherLocations.isEmpty {
            weatherLocations.append(WeatherLocation(name: "Current Location", latitude: 40.98, longitude: 29.03))
        }
    }
}
