//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 13.04.2021.
//

import Foundation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let mainRouter = MainRouter()
            window.rootViewController = UIHostingController(rootView: ContentView(viewModel: mainRouter.container.resolve(ContentViewModel.self)!))
            self.window = window
            window.makeKeyAndVisible()
            // TODO: - Zkopirovat reseni z JetYou
        }
    }
}
