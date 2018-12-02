//
//  RootController.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import UIKit

final class RootController: UIViewController {
  @IBOutlet private weak var viewController1: UIButton!
  
  var staticProps: StaticProps?
  var variableProps: VariableProps?
  
  @IBAction func goToViewController1(_ sender: UIButton) {
    self.variableProps?.dispatch.goToViewController1()
  }
}

extension RootController: ReduxCompatibleViewType {
  typealias OutProps = ()
  typealias StateProps = ()
  
  struct DispatchProps {
    let goToViewController1: () -> Void
  }
}
