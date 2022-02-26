//
//  AppDelegate.swift
//  Image TarckAR
//
//  Created by Narek Kirakosyan on 20.02.22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Determine who sent the URL.
            let sendingAppID = options[.sourceApplication]
            print("source application = \(sendingAppID ?? "Unknown")")

            // Process the URL.
        guard let vc = window?.rootViewController as? ViewController else { return false }
        
        let parsedUrl = url.relativeString.replacingOccurrences(of: "myImageTracker://url=", with: "")

        vc.imageUrl = parsedUrl
        
        
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                let albumPath = components.path,
                let params = components.queryItems else {
                    print("Invalid URL or album path missing")
                    return false
            }

            if let photoIndex = params.first(where: { $0.name == "index" })?.value {
                print("albumPath = \(albumPath)")
                print("photoIndex = \(photoIndex)")
                return true
            } else {
                print("Photo index missing")
                return false
            }
    }
}

