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
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
      .decode(at: Redux.Path.rootPath, ofType: StateProps.self)
      .getOrElse(StateProps())
  }
  
  static func map(dispatch: @escaping ReduxDispatch,
                  outProps: OutProps) -> DispatchProps {
    return DispatchProps(
      incrementNumber: {dispatch(Redux.NumberAction.add)},
      decrementNumber: {dispatch(Redux.NumberAction.minus)},
      updateSlider: {dispatch(Redux.SliderAction.input($0))},
      updateString: {dispatch(Redux.StringAction.input($0))},
      deleteText: {dispatch(Redux.TextAction.delete($0))},
      addOneText: {dispatch(Redux.TextAction.addItem)}
    )
  }
}

extension ConfirmButton: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return StateProps()
  }
  
  static func map(dispatch: @escaping ReduxDispatch,
                  outProps: OutProps) -> DispatchProps {
    return DispatchProps(
      confirmEdit: {dispatch(Redux.ClearAction.triggerClear)}
    )
  }
}

extension TableCell: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return StateProps(
      text: state.value(at: Redux.Path
        .textItemPath(outProps))
        .cast(String.self).value
    )
  }
  
  static func map(dispatch: @escaping ReduxDispatch,
                  outProps: OutProps) -> DispatchProps {
    return DispatchProps(
      updateText: {dispatch(Redux.TextAction.input(outProps, $0))}
    )
  }
}
