//
//  CustomPlace.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import GooglePlaces

class Place {
    
    var name: String
    var coordinate: CLLocationCoordinate2D?
    
    init(name: String) {
        self.name = name 
    }
    
    init(gmsPlace: GMSPlace) {
        self.name = gmsPlace.name ?? ""
        self.coordinate = gmsPlace.coordinate
    }
}
