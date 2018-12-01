//
//  NavigationController.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
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
      _ = Dependency.shared.injector.injectProps(controller: vc, outProps: ())
      
    default:
      break
    }
  }
}
