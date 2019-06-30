//
//  NavigationController.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/6/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

public final class NavigationController: UINavigationController {
  var dependency: Dependency?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
}

// MARK: - UINavigationControllerDelegate
extension NavigationController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) {
    switch viewController {
    case let vc as iTunesController:
      self.dependency?.propInjector.injectProps(controller: vc, outProps: ())
      
    default:
      fatalError()
    }
  }
}
