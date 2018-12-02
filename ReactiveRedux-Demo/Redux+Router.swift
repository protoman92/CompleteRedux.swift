//
//  Redux+Router.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import UIKit

public enum ReduxScreen: ReduxNavigationScreenType {
  case back
  case viewController1
}

public struct ReduxRouter: ReduxRouterType {
  public typealias Screen = ReduxScreen
  
  private weak var controller: UINavigationController?
  
  public init(_ controller: UINavigationController) {
    self.controller = controller
  }
  
  public func navigate(_ screen: ReduxScreen) {
    print("Navigating with screen: \(screen)")
    
    switch screen {
    case .viewController1:
      let vc = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "ViewController1")
        as! ViewController1
      
      self.controller?.pushViewController(vc, animated: true)
      
    case .back:
      self.controller?.popViewController(animated: true)
    }
  }
}
