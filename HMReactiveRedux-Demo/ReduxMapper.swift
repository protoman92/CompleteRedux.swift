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
  typealias State = SafeNest
  
  func map(state: State) -> StateProps? {
    return state.decode(at: Redux.Path.rootPath, ofType: StateProps.self).value
  }
  
  func map(dispatch: @escaping ReduxDispatch) -> DispatchProps? {
    return DispatchProps(
      clearAll: {dispatch(Redux.ClearAction.triggerClear)},
      incrementNumber: {dispatch(Redux.NumberAction.add)},
      decrementNumber: {dispatch(Redux.NumberAction.minus)},
      updateSlider: {dispatch(Redux.SliderAction.input($0))},
      updateString: {dispatch(Redux.StringAction.input($0))}
    )
  }
}
