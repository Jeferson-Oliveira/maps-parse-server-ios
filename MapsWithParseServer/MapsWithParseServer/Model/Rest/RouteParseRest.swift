//
//  RouteParseRest.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import Parse

class RouteParseRest: NSObject {

    func save(route: Route, onSucess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        Route.toPFObject(route: route).saveInBackground { (success: Bool, error: Error?) in
            if (success) {
               onSucess()
            } else {
                onError(error?.localizedDescription ?? "Não foi possível salvar sua rota, tente novamente mais tarde.")
            }
        }
    }
    
    func listAll(onSucess: @escaping ([Route]) -> Void, onError: @escaping (String) -> Void) {
        let query = PFQuery(className: Route.className)
        query.findObjectsInBackground { (results: [PFObject]?, error: Error?) in
            if let error = error {
                onError(error.localizedDescription)
            } else {
                guard let results = results else {return}
                var itens = [Route]()
                
                results.forEach({ pfObject in
                    itens.append(Route.toRoute(pfObject: pfObject))
                })
                onSucess(itens)
            }
        }
    }
    
    func delete(route: Route, onSucess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        Route.toPFObject(route: route).deleteInBackground(block: {(success: Bool, error: Error?) in
            if (success) {
                onSucess()
            } else {
                onError(error?.localizedDescription ?? "Não foi possível remover sua rota, tente novamente mais tarde.")
            }
        })
    }
}
