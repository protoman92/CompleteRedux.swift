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

/// Connector mapper that maps state/dispatch to redux props.
public protocol ReduxConnectorMapper {
  associatedtype State
  associatedtype View: ReduxConnectableView
  
  static func map(state: State) -> View.StateProps
  static func map(dispatch: @escaping ReduxDispatch) -> View.DispatchProps
  static func compareState(lhs: View.StateProps, rhs: View.StateProps) -> Bool
}

public extension ReduxConnectorMapper where View.StateProps: Equatable {
  public static func compareState(lhs: View.StateProps,
                                  rhs: View.StateProps) -> Bool {
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
    Mapper: ReduxConnectorMapper,
    Mapper.State == Store.State,
    Mapper.View == VC
  {
    let dispatchProps = Mapper.map(dispatch: self.store.dispatch)
    
    let cancel = self.store.subscribeState(
      subscriberId: vc.stateSubscriberId,
      selector: Mapper.map,
      comparer: Mapper.compareState,
      callback: {[weak vc] props in vc?.reduxProps = (props, dispatchProps)}
    )
    
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    vc.addChild(lifecycleVC)
    return cancel
  }
}

extension ReduxConnector {
  final class LifecycleViewController: UIViewController {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }
}
