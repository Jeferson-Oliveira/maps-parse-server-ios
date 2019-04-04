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

     func traceRouter(route: Route, onSuccess : @escaping ([GMSPolyline]) -> Void,  onError : @escaping (String) -> Void) {
        
        let origin = "\((route.source?.coordinate?.latitude ?? 0.0).description),\((route.source?.coordinate?.longitude ?? 0.0).description)"
        
        let destination = "\((route.target?.coordinate?.latitude ?? 0.0).description),\((route.target?.coordinate?.longitude ?? 0.0).description)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(AppDelegate.mapsKey)"
        
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess {
                var responseList = [GMSPolyline]()
                
                do {
                    let json = try JSON(data: response.data!)
                    let routes = json["routes"].arrayValue
                    
                    for route in routes
                    {
                        guard let routeOverviewPolyline = route["overview_polyline"].dictionary,
                            let points = routeOverviewPolyline["points"]?.stringValue else {
                                onError("Não foi possível obter o retorno do servidor")
                                return
                        }
                        
                        let path = GMSPath.init(fromEncodedPath: points)
                        responseList.append(GMSPolyline.init(path: path))
                        
                    }
                    onSuccess(responseList)
                } catch  {
                    onError("Não foi possível obter o retorno do servidor")
                }
                
            } else {
                onError(response.error?.localizedDescription ?? "Não foi possível obter sua rota")
            }

        }

    }
    
}
