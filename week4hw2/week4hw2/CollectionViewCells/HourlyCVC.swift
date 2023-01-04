//
//  HourlyCVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 5.01.2023.
//

import UIKit

class HourlyCVC: UICollectionViewCell {

    @IBOutlet weak var hourlyTimeLabel: UILabel!
    @IBOutlet weak var hourlyIconImageView: UIImageView!
    @IBOutlet weak var hourlyTempLabel: UILabel!
    
    var hourlyWeather: HourlyWeather! {
        didSet {
            hourlyTimeLabel.text = hourlyWeather.hour
            hourlyIconImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
            hourlyTempLabel.text = " \(hourlyWeather.hourlyTemperature)°"
        }
    }
}
