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
  associatedtype State
  
  /// Inject state/dispatch props into a compatible view controller.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: Store cancellable.
  @discardableResult
  func connect<VC, Mapper>(controller vc: VC, mapper: Mapper)
    -> ReduxUnsubscribe where
    VC: UIViewController,
    VC: ReduxCompatibleViewType,
    VC.PropsConnector == Self,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
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
    -> ReduxUnsubscribe where
    V: UIView,
    V: ReduxCompatibleViewType,
    V.PropsConnector == Self,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
}

public struct ReduxConnector<Store: ReduxStoreType>: ReduxConnectorType {
  public typealias State = Store.State
  private let store: Store
  
  public init(store: Store) {
    self.store = store
  }
  
  private func clone() -> ReduxConnector<Store> {
    return ReduxConnector(store: self.store)
  }
  
  private func connect<CV, Mapper>(compatibleView cv: CV, mapper: Mapper)
    -> ReduxUnsubscribe where
    CV: ReduxCompatibleViewType,
    CV.PropsConnector == ReduxConnector,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == CV.StateProps,
    Mapper.DispatchProps == CV.DispatchProps
  {
    let viewId = cv.stateSubscriberId
    cv.staticProps = StaticPropsContainer(self.clone())
    var previous: CV.StateProps? = nil
    
    return self.store.subscribeState(subscriberId: viewId) {[weak cv, weak mapper] state in
      // Since UI operations must happen on the main thread, we dispatch with
      // the main queue. Setting the previous props here is ok as well since
      // only the main queue is accessing it.
      DispatchQueue.main.async {
        let dispatch = mapper?.map(dispatch: self.store.dispatch)
        let next = mapper?.map(state: state)
        
        if previous == nil || !Mapper.compareState(lhs: previous, rhs: next) {
          cv?.variableProps = VariablePropsContainer(previous, next, dispatch)
          previous = next
        }
      }
    }
  }
  
  @discardableResult
  public func connect<VC, Mapper>(controller vc: VC, mapper: Mapper)
    -> ReduxUnsubscribe where
    VC: UIViewController,
    VC: ReduxCompatibleViewType,
    VC.PropsConnector == ReduxConnector,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == VC.StateProps,
    Mapper.DispatchProps == VC.DispatchProps
  {
    let cancel = self.connect(compatibleView: vc, mapper: mapper)
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    vc.addChild(lifecycleVC)
    return cancel
  }
  
  public func connect<V, Mapper>(view: V, mapper: Mapper)
    -> ReduxUnsubscribe where
    V: UIView,
    V: ReduxCompatibleViewType,
    V.PropsConnector == ReduxConnector,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
  {
    let cancel = self.connect(compatibleView: view, mapper: mapper)
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
