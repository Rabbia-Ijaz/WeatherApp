//
//  LocationTableViewCell.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 28/04/2024.
//

import UIKit

protocol LocationTableViewDelegate: AnyObject {
    func didSelectIndex(_ index: Int)
}

class LocationTableViewCell: UITableViewCell {
    static var identifier = "LocationTableViewCell"
    @IBOutlet var temperature:UILabel!
    @IBOutlet var time:UILabel!
    @IBOutlet var title:UILabel!
    
    weak var delegate: LocationTableViewDelegate?
        var index: Int = 0 // Add this property to hold the cell's index
        
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        // Don't call super.setSelected(_:animated:)
    }
    
    func setCellData(weatherResponse: WeatherResponse, isCentrigrade: Bool, index: Int) {
            self.index = index // Assign the index when setting cell data
        title.text = weatherResponse.name
        time.text = weatherResponse.date
        
        if isCentrigrade {
            temperature.text = "\(weatherResponse.main?.temp ?? 0)°C"
        } else {
            temperature.text = "\(weatherResponse.main?.tempInFahrenheit ?? 0)°F"
        }
    }
    
    @IBAction func inquiryBtnPressed(_ sender: Any) {
        delegate?.didSelectIndex(index)
    }
    
}
