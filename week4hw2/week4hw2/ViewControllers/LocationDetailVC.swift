//
//  LocationDetailVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import UIKit
import CoreLocation

class LocationDetailVC: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationTempLabel: UILabel!
    @IBOutlet weak var locationSummaryLabel: UILabel!
    @IBOutlet weak var locationMinMaxTempLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherDetail: WeatherDetail!
    var weatherLocations: [WeatherLocation] = []
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if weatherDetail == nil {
            weatherDetail = WeatherDetail(name: "Current Location", latitude: 40.0, longitude: 29.30)
            weatherLocations.append(weatherDetail)
        }
        
        clearData()
        loadLocations()
        updateUI()
        
        tableView.register(.init(nibName: "DailyTVC", bundle: nil), forCellReuseIdentifier: "DailyTVC")
        collectionView.register(.init(nibName: "HourlyCVC", bundle: nil), forCellWithReuseIdentifier: "HourlyCVC")
    }
    
    private func clearData() {
        locationNameLabel.text = ""
        locationTempLabel.text = ""
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
    
    private func updateUI() {
        weatherDetail.getData {
            DispatchQueue.main.async {
                self.locationNameLabel.text = self.weatherDetail.name
                self.locationTempLabel.text = "\(self.weatherDetail.temperature)"
                self.locationSummaryLabel.text = self.weatherDetail.summary
                self.locationMinMaxTempLabel.text = ""
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - TableView Delegate
extension LocationDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - TableView Datasource
extension LocationDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyTVC", for: indexPath) as! DailyTVC
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
        return cell
    }
}

// MARK: - CollectionView Delegate
extension LocationDetailVC: UICollectionViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - CollectionView Datasource
extension LocationDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDetail.hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCVC", for: indexPath) as! HourlyCVC
        hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
        return hourlyCell
    }
}

// MARK: - CLLoctionManager Delegate
extension LocationDetailVC: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthenticalStatus(status: status)
    }
    
    func handleAuthenticalStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("ERROR!")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Change device settings this app")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Error from openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        print("Current Location is: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            if placemarks != nil {
                let placemark = placemarks?.last
                locationName = placemark?.name ?? "Unknown"
            } else {
                print("ERROR: \(String(describing: error?.localizedDescription))")
                locationName = "Could not find location"
            }
        }
        
//        let pageViewController = UIApplication.shared.windows.first!.rootViewController as! PageVC
//        pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
//        pageViewController.weatherLocations[self.locationIndex].longitude = currentLocation.coordinate.longitude
//        pageViewController.weatherLocations[self.locationIndex].name = locationName
        
        self.updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}




