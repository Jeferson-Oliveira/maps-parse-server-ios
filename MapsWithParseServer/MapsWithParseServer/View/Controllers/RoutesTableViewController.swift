//
//  RoutesTableViewController.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import UIKit

class RoutesTableViewController: BaseViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblNoResults: UILabel!
    
    @IBOutlet weak var tbRoutes: UITableView!
    
    let refreshControl = UIRefreshControl()

    let routeRest = RouteParseRest()
    var routes = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadRoutes()
    }
    
    func configureTableView() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tbRoutes.refreshControl = refreshControl
        } else {
            tbRoutes.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(loadRoutes), for: .valueChanged)

    }
    
    @objc func loadRoutes() {
        self.loadingIndicator.startAnimating()
        routeRest.listAll(onSucess: { routes in
            self.loadingIndicator.stopAnimating()
            self.lblNoResults.isHidden = !routes.isEmpty
            self.routes = routes
            self.tbRoutes.reloadData()
            self.refreshControl.endRefreshing()
        }, onError: { erroMessage in
            self.showAlert(message: erroMessage, completion: {
                self.loadingIndicator.stopAnimating()
                self.lblNoResults.isHidden = false
            })
        })
    }
    
}

extension RoutesTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? RouteTableViewCell else {return UITableViewCell()}
        cell.setupCell(model: self.routes[indexPath.row], delegate: self)
        
        return cell
    }
}

extension RoutesTableViewController: RouteTableViewCellDelegate {
    func delete(route: Route) {
        self.loadingIndicator.startAnimating()
        routeRest.delete(route: route, onSucess: {
            self.loadingIndicator.stopAnimating()
            guard let routeIndex = self.routes.firstIndex(of: route) else {return}
            self.routes.remove(at: routeIndex)
            self.tbRoutes.beginUpdates()
            self.tbRoutes.deleteRows(at: [IndexPath(item: routeIndex, section: 0)], with: UITableView.RowAnimation.left)
            self.tbRoutes.endUpdates()
            self.lblNoResults.isHidden = !self.routes.isEmpty
        }, onError: { erroMessage in
            self.showAlert(message: erroMessage, completion: {
                self.loadingIndicator.stopAnimating()
            })
        })
    }
}


