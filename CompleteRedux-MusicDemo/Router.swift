//
//  Router.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/8/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import CompleteRedux
import UIKit

public enum AppScreen: RouterScreenType {
  case iTunesSearch
  case externalUrl(String?)
}

public final class AppRouter {
  private weak var controller: UINavigationController?
  
  public init(_ controller: UINavigationController) {
    self.controller = controller
  }
}

// MARK: - ReduxRouterType
extension AppRouter: ReduxRouterType {
  public func navigate(_ screen: RouterScreenType) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    switch screen as? AppScreen {
    case .some(.iTunesSearch):
      let vc = storyboard
        .instantiateViewController(withIdentifier: "iTunesController")
        as! iTunesController
      
      self.controller?.setViewControllers([vc], animated: true)
      
    case .some(.externalUrl(let urlString)):
      if let urlStr = urlString, let url = URL(string: urlStr) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
      
    default:
      fatalError("Unsupported screen \(screen)")
    }
  }
}
