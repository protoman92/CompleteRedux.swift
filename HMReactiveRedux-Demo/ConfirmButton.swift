//
//  ConfirmButton.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 11/29/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import HMReactiveRedux
import SafeNest
import UIKit

final class ConfirmButton: UIButton {
  var staticProps: StaticProps?
  var variableProps: VariableProps?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.addTarget(self, action: #selector(self.onClick), for: .touchDown)
  }
  
  @objc func onClick(_ sender: UIButton) {
    self.variableProps?.dispatch.confirmEdit()
  }
}

extension ConfirmButton: ReduxCompatibleViewType {
  struct StateProps: Equatable {}
  
  struct DispatchProps {
    let confirmEdit: () -> Void
  }
}
