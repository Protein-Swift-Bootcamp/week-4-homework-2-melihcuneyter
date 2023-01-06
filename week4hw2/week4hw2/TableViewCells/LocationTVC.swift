//
//  LocationTVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 4.01.2023.
//

import UIKit

class LocationTVC: UITableViewCell {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationSummaryLabel: UILabel!
    @IBOutlet weak var locationTempLabel: UILabel!
    @IBOutlet weak var locationIconImageView: UIImageView!
    
    var currentWeather: WeatherDetail! {
        didSet {
            locationNameLabel.text = currentWeather.name
            locationSummaryLabel.text = currentWeather.summary
            locationTempLabel.text = " \(currentWeather.temperature)°"
            locationIconImageView.image = UIImage(systemName: currentWeather.dayIcon)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .black
        contentView.layer.cornerRadius = 15
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
    }
}
