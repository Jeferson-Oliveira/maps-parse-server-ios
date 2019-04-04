//
//  Route.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import Parse


class Route: NSObject {
    
    static let className = "Route"
    
    var id: String?
    var source: Place?
    var target: Place?
    
    static func toPFObject(route: Route) -> PFObject {
        let pfRoute = PFObject(className: Route.className)
        if route.id != nil {
            pfRoute.objectId = route.id
        }
        pfRoute["source"] = route.source?.name ?? ""
        pfRoute["target"] = route.target?.name ?? ""
        return pfRoute
    }
    
    static func toRoute(pfObject: PFObject) -> Route {
        let route = Route()
        route.id = pfObject.objectId
        route.source = Place(name: pfObject.value(forKey: "target") as? String ?? "")
        route.target = Place(name: pfObject.value(forKey: "source") as? String ?? "")
        return route
    }
}
