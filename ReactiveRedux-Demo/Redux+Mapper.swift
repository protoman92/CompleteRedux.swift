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
      incrementNumber: {dispatch(AppRedux.Action.addNumber)},
      decrementNumber: {dispatch(AppRedux.Action.minusNumber)},
      updateSlider: {dispatch(AppRedux.Action.slider($0))},
      updateString: {dispatch(AppRedux.Action.string($0))},
      deleteText: {dispatch(AppRedux.Action.deleteTextItem($0))},
      addOneText: {dispatch(AppRedux.Action.addTextItem)}
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
      confirmEdit: {dispatch(AppRedux.Action.triggerClear)}
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
      updateText: {dispatch(AppRedux.Action.text(outProps, $0))}
    )
  }
}
