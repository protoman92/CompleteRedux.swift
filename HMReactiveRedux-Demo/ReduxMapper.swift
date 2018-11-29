//
//  ReduxMapper.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import HMReactiveRedux
import SafeNest

extension ViewController: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  func map(state: ReduxState) -> StateProps {
    return state
      .decode(at: Redux.Path.rootPath, ofType: StateProps.self)
      .getOrElse(StateProps())
  }
  
  func map(dispatch: @escaping ReduxDispatch) -> DispatchProps {
    return DispatchProps(
      incrementNumber: {dispatch(Redux.NumberAction.add)},
      decrementNumber: {dispatch(Redux.NumberAction.minus)},
      updateSlider: {dispatch(Redux.SliderAction.input($0))},
      updateString: {dispatch(Redux.StringAction.input($0))}
    )
  }
}

extension ConfirmButton: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  func map(state: ReduxState) -> StateProps {
    return StateProps()
  }
  
  func map(dispatch: @escaping ReduxDispatch) -> DispatchProps {
    return DispatchProps(
      confirmEdit: {dispatch(Redux.ClearAction.triggerClear)}
    )
  }
}
