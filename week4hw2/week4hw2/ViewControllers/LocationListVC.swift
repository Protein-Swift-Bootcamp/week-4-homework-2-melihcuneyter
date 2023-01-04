//
//  LocationListVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import UIKit
import GooglePlaces

class LocationListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    var weatherLocations: [WeatherLocation] = []
    var selectedLocationIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
    }
    
    private func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.set(encoded, forKey: "weatherLocations")
        } else {
            print("Error: Saving Encoded didn't work!")
        }
    }
    
//    //TODO: - Seguesiz yapma yolunu bul!
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
//        saveLocations()
//    }
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
        cell.locationNameLabel.text = weatherLocations[indexPath.row].name
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

// MARK: - AutocompleteResultsViewController Delegate
extension LocationListVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        let newLocation = WeatherLocation(name: place.name ?? "unkown place", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        weatherLocations.append(newLocation)
        tableView.reloadData()
        
        searchController.searchBar.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
}
