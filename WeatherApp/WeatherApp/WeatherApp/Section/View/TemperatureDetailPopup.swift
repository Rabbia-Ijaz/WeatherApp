//
//  TemperatureDetailPopup.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 04/05/2024.
//

import Foundation
import UIKit

class TemperatureDetailPopup: UIView {
    
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var closeButton: UIButton! // Connect this outlet to the close button in your XIB file
        
    // Add an action for the close button
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        removeFromSuperview() // Remove the popup from its superview when the close button is tapped
    }

}
