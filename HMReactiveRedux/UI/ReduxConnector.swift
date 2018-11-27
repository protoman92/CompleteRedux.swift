//
//  ReduxConnector.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import UIKit

/// A view that conforms to this protocol can receive state/dispatch props
/// and subscribe to state changes.
public protocol ReduxConnectableView: class {
  associatedtype StateProps
  associatedtype DispatchProps
  typealias ReduxProps = (state: StateProps, dispatch: DispatchProps)

  var stateSubscriberId: String { get }
  var reduxProps: ReduxProps? { get set }
}

public extension ReduxConnectableView where Self: UIViewController {
  public var stateSubscriberId: String {
    return self.restorationIdentifier ?? String(describing: self)
  }
}

public extension ReduxConnectableView where Self: UIView {
  public var stateSubscriberId: String {
    return self.accessibilityIdentifier ?? String(describing: self)
  }
}

/// Connector mapper that maps state/dispatch to redux props.
public protocol ReduxConnectorMapper {
  associatedtype State
  associatedtype StateProps
  associatedtype DispatchProps
  
  static func map(state: State) -> StateProps
  static func map(dispatch: @escaping ReduxDispatch) -> DispatchProps
  static func compareState(lhs: StateProps, rhs: StateProps) -> Bool
}

public extension ReduxConnectorMapper where StateProps: Equatable {
  public static func compareState(lhs: StateProps,
                                  rhs: StateProps) -> Bool {
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
  @discardableResult
  public func connect<VC, Mapper>(viewController vc: VC, mapper: Mapper.Type)
    -> Store.Cancellable where
    VC: UIViewController,
    VC: ReduxConnectableView,
    Mapper: ReduxConnectorMapper,
    Mapper.State == Store.State,
    Mapper.StateProps == VC.StateProps,
    Mapper.DispatchProps == VC.DispatchProps
  {
    let dispatchProps = Mapper.map(dispatch: self.store.dispatch)
    
    let cancel = self.store.subscribeState(
      subscriberId: vc.stateSubscriberId,
      selector: Mapper.map,
      comparer: Mapper.compareState
    ) { [weak vc] props in vc?.reduxProps = (props, dispatchProps) }
    
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    vc.addChild(lifecycleVC)
    return cancel
  }
  
  /// Inject state/dispatch props into a compatible view.
  ///
  /// - Parameter view: A View instance.
  public func connect<V, Mapper>(view: V, mapper: Mapper.Type)
    -> Store.Cancellable where
    V: UIView,
    V: ReduxConnectableView,
    Mapper: ReduxConnectorMapper,
    Mapper.State == Store.State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
  {
    let dispatchProps = Mapper.map(dispatch: self.store.dispatch)
    
    let cancel = self.store.subscribeState(
      subscriberId: view.stateSubscriberId,
      selector: Mapper.map,
      comparer: Mapper.compareState
    ) { [weak view] props in view?.reduxProps = (props, dispatchProps) }
    
    let lifecycleView = LifecycleView()
    lifecycleView.onDeinit = cancel
    view.addSubview(lifecycleView)
    return cancel
  }
}

extension ReduxConnector {
  final class LifecycleViewController: UIViewController {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }
  
  final class LifecycleView: UIView {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }
}
