//
//  RouteTableViewCell.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import UIKit

protocol RouteTableViewCellDelegate {
    func delete(route: Route)
}

class RouteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblTarget: UILabel!
    
    private var model: Route!
    private var delegate: RouteTableViewCellDelegate!
    
    func setupCell(model: Route, delegate: RouteTableViewCellDelegate) {
        self.model = model
        self.delegate = delegate
        self.lblSource.text = model.source?.name
        self.lblTarget.text = model.target?.name
    }
    
    @IBAction func delete() {
        self.delegate.delete(route: model)
    }
}
