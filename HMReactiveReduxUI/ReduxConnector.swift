//
//  Connect.swift
//  HMReactiveReduxUI
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import HMReactiveRedux
import UIKit

public protocol ReduxConnectableView {
  associatedtype State
  associatedtype StateProps: Equatable
  associatedtype DispatchProps
  typealias ReduxProps = (state: StateProps, dispatch: DispatchProps)
  
  static func mapStateToProps(state: State) -> StateProps
  static func mapDispatchToProps(dispatch: @escaping ReduxDispatch) -> DispatchProps
  var reduxProps: ReduxProps? { get set }
}

/// Connect views with state/dispatch props, similar to how React.js performs
/// connect.
public final class ReduxConnector<Store: ReduxStoreType> {
  private let store: Store
  
  public init(store: Store) {
    self.store = store
  }
  
  public func connect<View>(view: View) where
    View: UIViewController,
    View: ReduxConnectableView,
    View.State == Store.State
  {
    let dispatchProps = View.mapDispatchToProps(dispatch: self.store.dispatch)
    
    let cancel = self.store.subscribeState(
      selector: View.mapStateToProps,
      comparer: ==,
      callback: {[weak view] props in view?.reduxProps = (props, dispatchProps)}
    )
    
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    view.addChild(lifecycleVC)
  }
}

extension ReduxConnector {
  final class LifecycleViewController: UIViewController {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }
}
