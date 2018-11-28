//
//  ReduxConnector.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import UIKit

/// Connect views with state/dispatch props, similar to how React.js performs
/// connect.
public protocol ReduxConnectorType {
  associatedtype Store: ReduxStoreType
  
  /// Inject state/dispatch props into a compatible view controller.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: Store cancellable.
  @discardableResult
  func connect<VC, Mapper>(controller vc: VC, mapper: Mapper)
    -> Store.Cancellable where
    VC: UIViewController,
    VC: ReduxCompatibleViewType,
    VC.Connector == Self,
    Mapper: ReduxPropMapperType,
    Mapper.State == Store.State,
    Mapper.StateProps == VC.StateProps,
    Mapper.DispatchProps == VC.DispatchProps
  
  /// Inject state/dispatch props into a compatible view.
  ///
  /// - Parameters:
  ///   - view: A view instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: Store cancellable.
  @discardableResult
  func connect<V, Mapper>(view: V, mapper: Mapper)
    -> Store.Cancellable where
    V: UIView,
    V: ReduxCompatibleViewType,
    V.Connector == Self,
    Mapper: ReduxPropMapperType,
    Mapper.State == Store.State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
}

public struct ReduxConnector<Store: ReduxStoreType>: ReduxConnectorType {
  private let store: Store
  
  public init(store: Store) {
    self.store = store
  }
  
  @discardableResult
  public func connect<VC, Mapper>(controller vc: VC, mapper: Mapper)
    -> Store.Cancellable where
    VC: UIViewController,
    VC: ReduxCompatibleViewType,
    VC.Connector == ReduxConnector,
    Mapper: ReduxPropMapperType,
    Mapper.State == Store.State,
    Mapper.StateProps == VC.StateProps,
    Mapper.DispatchProps == VC.DispatchProps
  {
    let dispatchProps = mapper.map(dispatch: self.store.dispatch)
    vc.staticProps = StaticPropsContainer(self, dispatchProps)
    
    let cancel = self.store.subscribeState(
      subscriberId: vc.stateSubscriberId,
      selector: mapper.map,
      comparer: Mapper.compareState
    ) {[weak vc] props in vc?.variableProps = VariablePropsContainer(props)}
    
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    vc.addChild(lifecycleVC)
    return cancel
  }
  
  public func connect<V, Mapper>(view: V, mapper: Mapper)
    -> Store.Cancellable where
    V: UIView,
    V: ReduxCompatibleViewType,
    V.Connector == ReduxConnector,
    Mapper: ReduxPropMapperType,
    Mapper.State == Store.State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
  {
    let dispatchProps = mapper.map(dispatch: self.store.dispatch)
    view.staticProps = StaticPropsContainer(self, dispatchProps)
    
    let cancel = self.store.subscribeState(
      subscriberId: view.stateSubscriberId,
      selector: mapper.map,
      comparer: Mapper.compareState
    ) {[weak view] props in view?.variableProps = VariablePropsContainer(props)}
    
    let lifecycleView = LifecycleView()
    lifecycleView.onDeinit = cancel
    view.addSubview(lifecycleView)
    return cancel
  }
}

final class LifecycleViewController: UIViewController {
  deinit { self.onDeinit?() }
  var onDeinit: (() -> Void)?
}

final class LifecycleView: UIView {
  deinit { self.onDeinit?() }
  var onDeinit: (() -> Void)?
}
