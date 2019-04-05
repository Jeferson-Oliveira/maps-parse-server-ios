//
//  HomeViewController.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 02/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces

class HomeViewController: BaseViewController {

    @IBOutlet weak var txtSource: UITextField!
    @IBOutlet weak var txtTarget: UITextField!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    var gmsDataSource = CustomGMSAutocompleteTableDataSource()
    let googleMapsRest = GoogleMapsRest()
    let locationManager = CLLocationManager()
    let route = Route()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSave.isEnabled = false
    }
    
    override func loadView() {
        super.loadView()
        configureLocationManager()
        configureMapView()
        configureGMSDatasource()
        configureSearchFields()
        //hideKeyboardWhenTapAround()
    }
    
    @IBAction func saveRoute(_ sender: UIBarButtonItem) {
        guard let _ = self.route.source, let _ = self.route.target else {return}
        sender.isEnabled = false
        self.showActivityIndicator()
        RouteParseRest().save(route: self.route, onSucess: {
            sender.isEnabled = true
            self.showAlert(message: "Rota gravada com sucesso", completion: self.hideActivityIndicator)
        }) { (errorMessage) in
            sender.isEnabled = true
            self.showAlert(message: errorMessage, completion: self.hideActivityIndicator)
        }
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
    
    func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.appearAnimation = .pop
        marker.isFlat = true
        marker.map = self.mapView
    }

    func changeCamera(toLocation: CLLocationCoordinate2D) {
        self.mapView.camera = GMSCameraPosition.camera(withTarget: toLocation, zoom: 15 )
    }
    
    func traceRoute() {
        guard let sourceCordinate = route.source?.coordinate, let targetCordinate = route.target?.coordinate else {return}
        self.showActivityIndicator()
        googleMapsRest.traceRouter(route: self.route, onSuccess: { response in
            self.hideActivityIndicator()
            response.forEach({ item in
                item.strokeColor = UIColor.blue
                item.strokeWidth = 2
                item.map = self.mapView
            })
            self.addMarker(position: sourceCordinate)
            self.addMarker(position: targetCordinate)
            self.btnSave.isEnabled = true
        }, onError: { erroMessage in
            self.showAlert(message: erroMessage, completion: self.hideActivityIndicator)
        })
    }
}

extension HomeViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else {return}
        changeCamera(toLocation: currentLocation.coordinate)
        locationManager.stopUpdatingLocation()
    }

}


extension HomeViewController: GMSAutocompleteTableDataSourceDelegate {
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        self.autoCompleteTableView.isHidden = true
        
        if self.gmsDataSource.currentSearchTextField == self.txtSource {
            self.txtSource.text = place.name
            self.route.source = Place(gmsPlace: place)
            self.changeCamera(toLocation: place.coordinate)
            self.addMarker(position: place.coordinate)
            self.txtSource.resignFirstResponder()
        } else if self.gmsDataSource.currentSearchTextField == self.txtTarget {
            self.txtTarget.text = place.name
            self.route.target = Place(gmsPlace: place)
            self.txtTarget.resignFirstResponder()
        }
        
        self.gmsDataSource.currentSearchTextField = nil
        self.traceRoute()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        self.showActivityIndicator()
        self.autoCompleteTableView.reloadData()
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        self.hideActivityIndicator()
        self.autoCompleteTableView.reloadData()
    }

}

extension HomeViewController : UITextFieldDelegate {
    
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
        if let text = textField.text, !text.isEmpty {
            if(text.count > 3) {
                self.autoCompleteTableView.isHidden = false
                self.gmsDataSource.sourceTextHasChanged(text)
                self.gmsDataSource.currentSearchTextField = textField
            }
        } else {
            self.btnSave.isEnabled = false
            self.mapView.clear()
            if textField == txtSource {
                self.route.source = nil
            } else if textField == txtTarget {
                self.route.target = nil
            }
        }
    }
    
}
