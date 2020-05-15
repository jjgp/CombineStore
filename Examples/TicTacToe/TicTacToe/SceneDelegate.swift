//
//  SceneDelegate.swift
//  TicTacToe
//
//  Created by Jason Prasad on 5/13/20.
//  Copyright © 2020 Jason Prasad. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: RootView())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
