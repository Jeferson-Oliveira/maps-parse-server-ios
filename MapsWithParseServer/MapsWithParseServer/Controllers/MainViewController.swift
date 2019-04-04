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
        //hideKeyboardWhenTapAround()
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
        changeCamera(toLocation: currentLocation.coordinate)
        locationManager.stopUpdatingLocation()
    }
    
    func changeCamera(toLocation: CLLocationCoordinate2D) {
        self.mapView.camera = GMSCameraPosition.camera(withTarget: toLocation, zoom: 15 )
    }
    
    func traceRoute() {
        guard let _ = route.source, let _ = route.target else {return}
        self.mapView.clear()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GoogleMapsRest.traceRouter(route: self.route, onSuccess: { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            response.forEach({ item in
                item.strokeColor = UIColor.blue
                item.strokeWidth = 2
                item.map = self.mapView
            })
            
        }, onError: { erroMessage in
            
            let ac = UIAlertController(title: "Aviso", message: erroMessage, preferredStyle: UIAlertController.Style.alert)
            
            ac.addAction(UIAlertAction(title: "Entendi", style: UIAlertAction.Style.default, handler: {_ in
                ac.dismiss(animated: true, completion: nil)
            }))
            
            self.present(ac, animated: true, completion: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        })
    }
    
    
}


extension MainViewController: GMSAutocompleteTableDataSourceDelegate {
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        self.autoCompleteTableView.isHidden = true
        
        if self.gmsDataSource.currentSearchTextField == self.txtSource {
            self.txtSource.text = place.name
            self.route.source = place.coordinate
            self.changeCamera(toLocation: place.coordinate)
            self.txtSource.resignFirstResponder()
        } else if self.gmsDataSource.currentSearchTextField == self.txtTarget {
            self.txtTarget.text = place.name
            self.route.target = place.coordinate
            self.txtTarget.resignFirstResponder()
        }
    
        self.gmsDataSource.currentSearchTextField = nil
        self.traceRoute()
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
        if let text = textField.text, !text.isEmpty {
            if(text.count > 5) {
                self.autoCompleteTableView.isHidden = false
                self.gmsDataSource.sourceTextHasChanged(text)
                self.gmsDataSource.currentSearchTextField = textField
            }
        } else {
            self.mapView.clear()
            if textField == txtSource {
                self.route.source = nil
            } else if textField == txtTarget {
                self.route.target = nil
            }
        }
        
    }
    
}
