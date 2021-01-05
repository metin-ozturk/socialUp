//
//  AppDelegate.swift
//  socialUp
//
//  Created by Metin Öztürk on 15.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import InstantSearch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

//        let rootVC = HomeVC()
//        let navigationController = UINavigationController(rootViewController: rootVC)
//        navigationController.setNavigationBarHidden(true, animated: false)
//        
//        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
//        window?.rootViewController = navigationController
        
        registerForNotifications(application: application)
        
        Messaging.messaging().delegate = self
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        InstantSearch.shared.configure(appID: "3UQQK7YRC5", apiKey: "2b6893313fb23c6d06eed7c75730d41e", index: "usersAndEvents")

        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("LEYLA", userInfo["aps"])
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var fbHandle = false
        var googleHandle = false
        
        
        fbHandle = ApplicationDelegate.shared.application(app, open: url, sourceApplication: (options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String), annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        googleHandle = GIDSignIn.sharedInstance().handle(url)
        
        
        return fbHandle || googleHandle
    }
    
    private func registerForNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

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

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {

//      let dataDict:[String: String] = ["token": fcmToken]
//      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
        if let userID = Auth.auth().currentUser?.uid {            Firestore.firestore().collection("users").document(userID).updateData(["CloudMessagingToken" : fcmToken])
        }
    }
    
    
}


