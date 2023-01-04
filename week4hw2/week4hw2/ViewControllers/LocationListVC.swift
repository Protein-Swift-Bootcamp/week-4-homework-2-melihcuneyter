//
//  LocationListVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import UIKit
import GooglePlaces

class LocationListVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherLocations: [WeatherLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var weatherLocation = WeatherLocation(name: "Istanbul", latitude: 0, longitude: 0)
        weatherLocations.append(weatherLocation)
        weatherLocation = WeatherLocation(name: "Manisa", latitude: 0, longitude: 0)
        weatherLocations.append(weatherLocation)
        weatherLocation = WeatherLocation(name: "Izmir", latitude: 0, longitude: 0)
        weatherLocations.append(weatherLocation)
        
        setupTableViewUI()
    }
    
    private func setupTableViewUI() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.register(.init(nibName: "LocationTVC", bundle: nil), forCellReuseIdentifier: "LocationTVC")
    }
}

// MARK: - TableView Delegate
extension LocationListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted Location")
            
            self.weatherLocations.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - SearchBar Delegate
extension LocationListVC: UISearchBarDelegate {
    // When tapped searchbar, present autocompleteVC
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}

// MARK: - GMSAutoComplete Delegate
extension LocationListVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let newLocation = WeatherLocation(name: place.name ?? "unkown place", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        weatherLocations.append(newLocation)
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
