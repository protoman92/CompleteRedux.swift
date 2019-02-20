//
//  Redux+Mapper.swift
//  SwiftRedux-Demo
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux
import SafeNest

extension RootController: ReduxPropMapperType {
  typealias ReduxState = SafeNest
  
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps {
    return ()
  }
  
  static func mapAction(dispatch: @escaping Redux.Store.Dispatch,
                        state: ReduxState,
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
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
      .decode(at: AppRedux.Path.rootPath, ofType: StateProps.self)
      .getOrElse(StateProps())
  }
  
  static func mapAction(dispatch: @escaping Redux.Store.Dispatch,
                        state: ReduxState,
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
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps {
    return StateProps()
  }
  
  static func mapAction(dispatch: @escaping Redux.Store.Dispatch,
                        state: ReduxState,
                        outProps: OutProps) -> ActionProps {
    return ActionProps(
      confirmEdit: {dispatch(AppRedux.Action.triggerClear)}
    )
  }
}

extension TableCell: ReduxPropMapperType {  
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps {
    return StateProps(
      text: state.value(at: AppRedux.Path
        .textItemPath(outProps))
        .cast(String.self).value
    )
  }
  
  static func mapAction(dispatch: @escaping Redux.Store.Dispatch,
                        state: ReduxState,
                        outProps: OutProps) -> ActionProps {
    return ActionProps(
      updateText: {dispatch(AppRedux.Action.text(outProps, $0))}
    )
  }
}
