//
//  GoogleMapsRest.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import Alamofire
import GoogleMaps
import SwiftyJSON

class GoogleMapsRest: NSObject {
    
    
    static func traceRouter(route: Route, onSuccess : @escaping ([GMSPolyline]) -> Void,  onError : @escaping (String) -> Void) {
        
        let origin = "\((route.source?.latitude ?? 0.0).description),\((route.source?.longitude ?? 0.0).description)"
        
        let destination = "\((route.target?.latitude ?? 0.0).description),\((route.target?.longitude ?? 0.0).description)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess {
//                let json = JSON(data: response.data!)
//                let routes = json["routes"].arrayValue
//
//                for route in routes
//                {
//                    let routeOverviewPolyline = route["overview_polyline"].dictionary
//                    let points = routeOverviewPolyline?["points"]?.stringValue
//                    let path = GMSPath.init(fromEncodedPath: points!)
//                    let polyline = GMSPolyline.init(path: path)
//                    polyline.strokeColor = UIColor.blue
//                    polyline.strokeWidth = 2
//                    polyline.map = self.googleView
//                }
            } else {
                onError(response.error?.localizedDescription ?? "Não foi possível obter sua rota")
            }


        }

    }
    
}
