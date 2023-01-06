//
//  LocationListVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import UIKit
import GooglePlaces
import CoreLocation

class LocationListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchController = UISearchController()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    var weatherLocations: [WeatherDetail] = []
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadLocations()
        
    }
    
    private func setupUI() {
        title = "Hava Durumu"
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.register(.init(nibName: "LocationTVC", bundle: nil), forCellReuseIdentifier: "LocationTVC")
        
        // MARK: GMSAutoComplete SearchController add NavigationItem and ResultViewController
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Şehir veya konum arayın."
        navigationItem.searchController = searchController
        
        appeareanceUpdate()
    }
    
    private func addLocation(weatherDetail: WeatherDetail) {
        weatherDetail.getData {
            DispatchQueue.main.async {
                self.weatherLocations.append(weatherDetail)
                self.tableView.reloadData()
                self.saveLocations()
            }
        }
    }
    
   private func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.set(encoded, forKey: "weatherLocations")
        } else {
            print("Error: Saving Encoded didn't work!")
        }
    }
    
    private func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            getLocation()
            return
        }
        
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherDetail] {
            self.weatherLocations = weatherLocations
            self.getDataDetail()
        } else {
            getLocation()
            print("Error: Couldn't decode data read from UserDefaults.")
        }
    }
    
    private func getDataDetail() {
        let group = DispatchGroup()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        for weatherLocation in self.weatherLocations {
            group.enter()
            weatherLocation.getData {
                group.leave()
            }
        }
        
        group.notify(queue: .main){
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableView Delegate
extension LocationListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        
        let vc = UIStoryboard(name: "Main", bundle:Bundle.main).instantiateViewController(withIdentifier:"LocationDetailVC") as! LocationDetailVC
        let weatherDetail = weatherLocations[indexPath.row]
        vc.weatherDetail = weatherDetail
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: - TableView DataSource
extension LocationListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTVC", for: indexPath) as! LocationTVC
        let weatherDetail = weatherLocations[indexPath.row]
        cell.currentWeather = weatherDetail
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted Location")
            
            self.weatherLocations.remove(at: indexPath.row)
            self.saveLocations()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Freezing first element
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row != 0 ? true : false)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row != 0 ? true : false)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return (proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath)
    }
}

// MARK: - AutocompleteResultsViewController Delegate
extension LocationListVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        let weatherDetail = WeatherDetail(name: place.name ?? "unkown place", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        addLocation(weatherDetail: weatherDetail)
        
        searchController.searchBar.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
}

// MARK: - CLLoctionManager Delegate
extension LocationListVC: CLLocationManagerDelegate {
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
                let weatherDetail = WeatherDetail(name: locationName, latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                self.addLocation(weatherDetail: weatherDetail)
            } else {
                print("ERROR: \(String(describing: error?.localizedDescription))")
                locationName = "Could not find location"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}




