//
//  ConfirmButton.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 11/29/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
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
  typealias OutProps = ()
  
  struct StateProps: Equatable {}
  
  struct DispatchProps {
    let confirmEdit: () -> Void
  }
}
