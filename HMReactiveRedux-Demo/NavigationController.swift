//
//  NavigationController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import HMReactiveReduxUI
import UIKit

final class NavigationController: UINavigationController {
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
}

extension NavigationController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController,
                            animated: Bool) {
    switch viewController {
    case let vc as ViewController:
      Dependency.instance.connector.connect(view: vc)
      
    default:
      break
    }
  }
}
