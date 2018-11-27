//
//  ReduxConnector.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import UIKit

public protocol ReduxConnectableView {
  associatedtype State
  associatedtype StateProps
  associatedtype DispatchProps
  typealias ReduxProps = (state: StateProps, dispatch: DispatchProps)
  
  static func mapStateToProps(state: State) -> StateProps
  static func mapDispatchToProps(dispatch: @escaping ReduxDispatch) -> DispatchProps
  static func compareState(lhs: StateProps, rhs: StateProps) -> Bool
  var reduxProps: ReduxProps? { get set }
}

public extension ReduxConnectableView where StateProps: Equatable {
  public static func compareState(lhs: StateProps, rhs: StateProps) -> Bool {
    return lhs == rhs
  }
}

/// Connect views with state/dispatch props, similar to how React.js performs
/// connect.
public struct ReduxConnector<Store: ReduxStoreType> {
  private let store: Store
  
  public init(store: Store) {
    self.store = store
  }
  
  /// Inject state/dispatch props into a compatible view controller.
  ///
  /// - Parameter view: A View instance.
  public func connect<VC>(viewController vc: VC) where
    VC: UIViewController,
    VC: ReduxConnectableView,
    VC.State == Store.State
  {
    let dispatchProps = VC.mapDispatchToProps(dispatch: self.store.dispatch)
    
    let cancel = self.store.subscribeState(
      selector: VC.mapStateToProps,
      comparer: VC.compareState,
      callback: {[weak vc] props in vc?.reduxProps = (props, dispatchProps)}
    )
    
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    vc.addChild(lifecycleVC)
  }
}

extension ReduxConnector {
  final class LifecycleViewController: UIViewController {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }
}
