//
//  AppDelegate.swift
//  supergrate
//
//  Created by Dreams on 20/06/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import VideoEditorSDK
import TwitterKit
import SCSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static var sharedInstance: AppDelegate = {
        let instance = AppDelegate()
        return instance
    }()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if let licenseURL = Bundle.main.url(forResource: "vesdk_ios_license", withExtension: "") {
            VESDK.unlockWithLicense(at: licenseURL)
        }

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.sharedInstance = self
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        TWTRTwitter.sharedInstance().start(withConsumerKey:"DWkClxPHCao4dxPoBi4lNtxbs", consumerSecret:"t6exoD8fR7bwcTWCL61Cgc95oY2EjOQerTCSzLeF0ebpnUoAn1")
        SCSDKSnapKit.initSDK()
        if Loggdinuser.value(forKey: USERLOGIN) != nil {
            let loginuser = Loggdinuser.value(forKey: USERLOGIN)as? Bool
            if loginuser == true {
               AppData.sharedInstance.user = UserDefaultHelper.getUser()
               navigateToHomeScreen()
            }
            else {
                navigateToLoginScreen()
            }
        }
        else {
            navigateToLoginScreen()
        }
        // Override point for customization after application launch.
        return true
    }
    
    func navigateToHomeScreen() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "navigation") as? UINavigationController
        AppDelegate.sharedInstance.window?.rootViewController = vc
    }
    
    func navigateToLoginScreen() {
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "AuthNavigation") as? UINavigationController {
        AppDelegate.sharedInstance.window?.rootViewController = vc
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("appurl:-\(url)")
        
        return GIDSignIn.sharedInstance.handle(url) || TWTRTwitter.sharedInstance().application(app, open: url, options: options) || ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
    }

}

