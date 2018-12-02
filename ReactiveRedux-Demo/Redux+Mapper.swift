//
//  Redux+Mapper.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import SafeNest

extension RootController: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return ()
  }
  
  static func map(dispatch: @escaping Redux.Dispatch,
                  outProps: OutProps) -> ActionProps {
    return ActionProps(
      goToViewController1: {dispatch(ReduxScreen.viewController1)}
    )
  }
  
  static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool {
    return true
  }
}

extension ViewController1: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
      .decode(at: AppRedux.Path.rootPath, ofType: StateProps.self)
      .getOrElse(StateProps())
  }
  
  static func map(dispatch: @escaping Redux.Dispatch,
                  outProps: OutProps) -> ActionProps {
    return ActionProps(
      goBack: {dispatch(ReduxScreen.back)},
      incrementNumber: {dispatch(AppRedux.NumberAction.add)},
      decrementNumber: {dispatch(AppRedux.NumberAction.minus)},
      updateSlider: {dispatch(AppRedux.SliderAction.input($0))},
      updateString: {dispatch(AppRedux.StringAction.input($0))},
      deleteText: {dispatch(AppRedux.TextAction.delete($0))},
      addOneText: {dispatch(AppRedux.TextAction.addItem)}
    )
  }
}

extension ConfirmButton: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return StateProps()
  }
  
  static func map(dispatch: @escaping Redux.Dispatch,
                  outProps: OutProps) -> ActionProps {
    return ActionProps(
      confirmEdit: {dispatch(AppRedux.ClearAction.triggerClear)}
    )
  }
}

extension TableCell: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return StateProps(
      text: state.value(at: AppRedux.Path
        .textItemPath(outProps))
        .cast(String.self).value
    )
  }
  
  static func map(dispatch: @escaping Redux.Dispatch,
                  outProps: OutProps) -> ActionProps {
    return ActionProps(
      updateText: {dispatch(AppRedux.TextAction.input(outProps, $0))}
    )
  }
}
