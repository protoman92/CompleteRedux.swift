//
//  AppDelegate.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux
import UIKit

@UIApplicationMain
public final class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
  {
    guard let topController = self.window?.rootViewController as? NavigationController else {
      fatalError()
    }
    
    let api = AppAPI(URLSession.shared)
    let repository = AppRepository(api, JSONDecoder())
    let router = AppRouter(topController)
    let sagas = AppSaga.sagas(repository)
    
    let store = applyMiddlewares([
      RouterMiddleware(router: router).middleware,
      SagaMiddleware(effects: sagas).middleware
      ])(SimpleStore.create(AppState(), AppReducer.reduce))

    let dependency = Dependency(store: store)
    topController.dependency = dependency
    return true
  }

  public func applicationWillResignActive(_ application: UIApplication) {}
  public func applicationDidEnterBackground(_ application: UIApplication) {}
  public func applicationWillEnterForeground(_ application: UIApplication) {}
  public func applicationDidBecomeActive(_ application: UIApplication) {}
  public func applicationWillTerminate(_ application: UIApplication) {}
}

