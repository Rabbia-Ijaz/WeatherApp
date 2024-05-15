//
//  MainViewController.swift
//  WeatherApp
//
//  Created by Rabbia Ijaz on 28/04/2024.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class MainViewController: UIViewController, LocationTableViewDelegate {
   
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var currentCityTemp: UILabel!
    @IBOutlet weak var currentCityName: UILabel!
    @IBOutlet weak var tempFormatSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    var viewModel: MainViewModel!
    let locationManager = CLLocationManager()

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainViewModel()
        setUI()
    }
    
    private func setUI() {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icon")
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        textField.leftView = imageView
        textField.leftViewMode = .always
        
        setTableView()
        searchTextField.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        tempFormatSwitch.tintColor = .lightGray
        tempFormatSwitch.layer.cornerRadius = 14
        tempFormatSwitch.backgroundColor = .lightGray
        tempFormatSwitch.onTintColor = .lightGray
        tempFormatSwitch.clipsToBounds = true
        
       locationManager.requestLocation()
    }
    
    private func setTableView() {
        tableView.register(UINib(nibName: "LocationTableViewCell", bundle: .main), forCellReuseIdentifier: "LocationTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setFirstCurrentLocation() {
        currentLocationBtnPressed(UIButton())
    }
    
    func didSelectIndex(_ index: Int) {
        let weatherResponse = viewModel.resultsList[index]
        showPopup(place: weatherResponse.name ?? "", minTemperature: "\(weatherResponse.main?.tempMin ?? 0)", maxTemperature: "\(weatherResponse.main?.tempMax ?? 0)")
    }
    
}

//MARK: IBAction
extension MainViewController {
    @IBAction func currentLocationBtnPressed(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    @IBAction func tempSwitchToggle(_ sender: UISwitch) {
        if sender.isOn { // Centigrade
            self.currentCityTemp.text = "\(viewModel.weatherResponse?.main?.temp ?? 10)°C"
        } else { // Farenheit
            self.currentCityTemp.text = "\(viewModel.weatherResponse?.main?.tempInFahrenheit ?? 10)°F"
        }
        tableView.reloadData()
    }
    
    func showPopup(place: String, minTemperature: String, maxTemperature: String) {
        // Load the TemperatureDetailPopup view from the nib file
        if let popupView = Bundle.main.loadNibNamed("TemperatureDetailPopup", owner: self, options: nil)?.first as? TemperatureDetailPopup {
            // Customize the content of the popup view
            popupView.place.text = place
            popupView.minTemp.text = minTemperature
            popupView.maxTemp.text = maxTemperature
            popupView.graphView.layer.cornerRadius = 15
            // Customize the appearance of the popup view if needed
            
            // Add the popup view as a subview
            popupView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            view.addSubview(popupView)
        }
    }
    
    func requestCurrentWeather(longitude:Double,latitude:Double) {
        viewModel.fetchWeatherForCurrentLocation(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    if let _ = weatherData.name {
                        print("Current weather in \(weatherData.name ?? ""): \(weatherData.main?.temp ?? 0)°C")
                        self.currentCityName.text = weatherData.name ?? ""
                        
                        if self.tempFormatSwitch.isOn {
                            self.currentCityTemp.text = "\(weatherData.main?.temp ?? 0)°C"
                        } else {
                            self.currentCityTemp.text = "\(weatherData.main?.tempInFahrenheit ?? 0)°F"
                        }
                        self.currentWeatherView.backgroundColor = self.viewModel.backgroundColor
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("Failed to fetch current weather data: \(error)")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // Permission granted, fetch weather for current location
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            print("Failed to get current location")
            return
        }
        
        requestCurrentWeather(longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

//MARK: Table View
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.resultsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as! LocationTableViewCell
        cell.delegate = self
        cell.setCellData(weatherResponse: viewModel.resultsList[indexPath.row], isCentrigrade: tempFormatSwitch.isOn, index: indexPath.row)
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.rightViewMode = .whileEditing
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if updatedText.isEmpty {
            textField.rightViewMode = .never
        } else {
            textField.rightViewMode = .whileEditing
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let city = searchTextField.text, !city.isEmpty else {
            textField.resignFirstResponder() // Dismiss the keyboard
            textField.text = ""
            return false // Prevent further action for empty city
        }
        
        viewModel.fetchWeather(forCity: city) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    if let _ = weatherData.name {
                        print("Weather in \(weatherData.name ?? ""): \(weatherData.main?.temp ?? 0)°C")
                        self.currentCityName.text = weatherData.name ?? ""
                        if self.tempFormatSwitch.isOn {
                            self.currentCityTemp.text = "\(weatherData.main?.temp ?? 0)°C"
                        } else {
                            self.currentCityTemp.text = "\(weatherData.main?.tempInFahrenheit ?? 0)°F"
                        }
                        self.currentWeatherView.backgroundColor = self.viewModel.backgroundColor
                        
                        self.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print("Failed to fetch weather data: \(error)")
            }
        }
        
        textField.resignFirstResponder() // Dismiss the keyboard
        textField.text = ""
        return true
    }

}
