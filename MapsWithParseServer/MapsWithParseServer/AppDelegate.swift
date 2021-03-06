//
//  AppDelegate.swift
//  MapsWithParseServer
//
//  Created by Jeferson Oliveira Cequeira de Jesus on 02/04/19.
//  Copyright © 2019 Jeferson Oliveira Cequeira de Jesus. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    #error ("Add mapskey.")
    static let mapsKey = ""
    static let parserAppID = "parser-server-demo-id"
    static let parseClientKey = "parser-server-demo-key"
    static let parserServerUrlString = "http://localhost:1337/parse"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Google Maps and Places Configuration
        GMSServices.provideAPIKey(AppDelegate.mapsKey)
        GMSPlacesClient.provideAPIKey(AppDelegate.mapsKey)
        
        //Pase Server Configuration
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = AppDelegate.parserAppID
            //$0.clientKey = AppDelegate.parseClientKey
            $0.server = AppDelegate.parserServerUrlString
        }
        Parse.initialize(with: parseConfig)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

