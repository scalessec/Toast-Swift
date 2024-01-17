//
//  AppDelegate.swift
//  Toast-Swift
//
//  Copyright (c) 2015-2024 Charles Scalesse.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    #if !os(visionOS)
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    #else
    lazy var window: UIWindow? = UIWindow()
    #endif
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let viewController = ViewController(style: .plain)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        configureAppearance()
        
        return true
    }
    
    private func configureAppearance() {
        let navigationBarColor: UIColor = .lightBlue
        let titleTextAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let appearance = UINavigationBar.appearance()
        if #available(iOS 15, *) {
            let barAppearance = UINavigationBarAppearance()
            barAppearance.backgroundColor =  navigationBarColor
            barAppearance.titleTextAttributes = titleTextAttributes
            appearance.standardAppearance = barAppearance
            appearance.scrollEdgeAppearance = barAppearance
        } else {
            appearance.barTintColor = navigationBarColor
            appearance.titleTextAttributes = titleTextAttributes
        }
    }
}

// MARK: - Theming

extension UIColor {
    
    static var lightBlue: UIColor {
        return UIColor(red: 76.0 / 255.0, green: 152.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
    }
    
    static var darkBlue: UIColor {
        return UIColor(red: 62.0 / 255.0, green: 128.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0)
    }
    
}

