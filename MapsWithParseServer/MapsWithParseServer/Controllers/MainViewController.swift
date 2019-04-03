//
//  ViewController.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 02/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces

class MainViewController: UIViewController {

    @IBOutlet weak var txtSource: UITextField!
    @IBOutlet weak var txtTarget: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnRoute: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    var gmsDataSource = CustomGMSAutocompleteTableDataSource()

    let locationManager = CLLocationManager()
    let route = Route()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        configureLocationManager()
        configureMapView()
        configureGMSDatasource()
        configureSearchFields()
        hideKeyboardWhenTapAround()
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func hideKeyboardWhenTapAround() {
        //view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(hideKeyboard)))
    }
    
    func configureSearchFields() {
        self.txtSource.delegate = self
        self.txtSource.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        self.txtTarget.delegate = self
        self.txtTarget.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func configureGMSDatasource() {
        self.gmsDataSource.delegate = self
        self.autoCompleteTableView.delegate = self.gmsDataSource
        self.autoCompleteTableView.dataSource = self.gmsDataSource
        
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func configureMapView() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }


}

extension MainViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else {return}
        mapView.camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: 15 )
        locationManager.stopUpdatingLocation()
    }
    
}


extension MainViewController: GMSAutocompleteTableDataSourceDelegate {
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        self.autoCompleteTableView.isHidden = true
        
        if self.gmsDataSource.currentSearchTextField == self.txtSource {
            self.txtSource.text = place.formattedAddress
            self.route.source = place.coordinate
            self.txtSource.resignFirstResponder()
        } else if self.gmsDataSource.currentSearchTextField == self.txtTarget {
            self.txtTarget.text = place.formattedAddress
            self.route.target = place.coordinate
            self.txtTarget.resignFirstResponder()
        }
        
        self.gmsDataSource.currentSearchTextField = nil
        
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.autoCompleteTableView.reloadData()
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.autoCompleteTableView.reloadData()
    }

}


extension MainViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.autoCompleteTableView.isHidden = true
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.autoCompleteTableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.autoCompleteTableView.isHidden = true
        textField.resignFirstResponder()
    }
    
    func doneButtonAction(_ field: UITextField) {
        _ = textFieldShouldReturn(field)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if(text.count > 5) {
                self.autoCompleteTableView.isHidden = false
                self.gmsDataSource.sourceTextHasChanged(text)
                self.gmsDataSource.currentSearchTextField = textField
            }
        }
        
    }
    
}
