//
//  RootController.swift
//  SwiftRedux-Demo
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux
import UIKit

final class RootController: UIViewController {
  @IBOutlet private weak var viewController1: UIButton!
  
  var staticProps: StaticProps?
  var variableProps: VariableProps?
  
  @IBAction func goToViewController1(_ sender: UIButton) {
    self.variableProps?.action.goToViewController1()
  }
}

extension RootController: ReduxCompatibleViewType {
  typealias OutProps = ()
  typealias StateProps = ()
  
  struct ActionProps {
    let goToViewController1: () -> Void
  }
}
