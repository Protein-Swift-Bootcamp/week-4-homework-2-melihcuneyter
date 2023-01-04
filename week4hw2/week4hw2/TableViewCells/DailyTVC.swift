//
//  DailyTVC.swift
//  week4hw2
//
//  Created by Melih Cüneyter on 5.01.2023.
//

import UIKit

class DailyTVC: UITableViewCell {

    @IBOutlet weak var dailyWeekdayLabel: UILabel!
    @IBOutlet weak var dailyIconImageView: UIImageView!
    @IBOutlet weak var dailyHighTempLabel: UILabel!
    @IBOutlet weak var dailyLowTempLabel: UILabel!
    
    var dailyWeather: DailyWeather! {
        didSet {
            dailyIconImageView.image = UIImage(systemName: dailyWeather.dailyIcon)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailyHighTempLabel.text = "Max: \(dailyWeather.dailyHigh)°"
            dailyLowTempLabel.text = "Min:  \(dailyWeather.dailyLow)°"
        }
    }
}
