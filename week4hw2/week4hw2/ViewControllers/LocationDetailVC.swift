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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherDetail: WeatherDetail!
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        tableView.register(.init(nibName: "DailyTVC", bundle: nil), forCellReuseIdentifier: "DailyTVC")
        collectionView.register(.init(nibName: "HourlyCVC", bundle: nil), forCellWithReuseIdentifier: "HourlyCVC")
    }
    
    private func setupUI() {
        locationNameLabel.text = weatherDetail.name
        locationTempLabel.text = "\(weatherDetail.temperature)"
        locationSummaryLabel.text = weatherDetail.summary
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    @IBAction func showListView(_ sender: Any) {
        self.dismiss(animated: true)
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
