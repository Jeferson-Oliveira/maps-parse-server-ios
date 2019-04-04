//
//  BaseViewController.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 03/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func hideActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func showAlert(title: String = "Aviso", message: String, completion: (() -> Void)?) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        ac.addAction(UIAlertAction(title: "Entendi", style: UIAlertAction.Style.default, handler: {_ in
            ac.dismiss(animated: true, completion: nil)
        }))
        
        self.present(ac, animated: true, completion: {
            completion?()
        })
    }
}
