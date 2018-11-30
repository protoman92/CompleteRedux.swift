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
public protocol ReduxPropInjectorType {
  associatedtype State
  
  /// Inject state/dispatch props into a compatible view controller.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: Store cancellable.
  @discardableResult
  func injectProps<VC, Mapper>(controller vc: VC, mapper: Mapper)
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
  func injectProps<V, Mapper>(view: V, mapper: Mapper)
    -> ReduxUnsubscribe where
    V: UIView,
    V: ReduxCompatibleViewType,
    V.PropsConnector == Self,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
}

public struct ReduxInjector<Store: ReduxStoreType>: ReduxPropInjectorType {
  public typealias State = Store.State
  private let store: Store
  
  public init(store: Store) {
    self.store = store
  }
  
  private func injectProps<CV, Mapper>(compatibleView cv: CV, mapper: Mapper)
    -> ReduxUnsubscribe where
    CV: ReduxCompatibleViewType,
    CV.PropsConnector == ReduxInjector,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == CV.StateProps,
    Mapper.DispatchProps == CV.DispatchProps
  {
    // Here we use the view's class name and a timestamp as the subscription
    // id. We don't even need to store this id because we can simply cancel
    // with the returned unsubscription callback (so the id can be literally
    // anything, as long as it is unique).
    let timestamp = Date().timeIntervalSince1970
    let viewId = String(describing: cv) + String(describing: timestamp)
    var previous: CV.StateProps? = nil
    var first = true
    
    // If there has been a previous subscription, unsubscribe from it to avoid
    // having parallel subscriptions.
    cv.staticProps?.unsubscribe()
    
    let unsubscribe = self.store
      .subscribeState(subscriberId: viewId) {[weak cv, weak mapper] state in
        // Since UI operations must happen on the main thread, we dispatch with
        // the main queue. Setting the previous props here is ok as well since
        // only the main queue is accessing it.
        DispatchQueue.main.async {
          if let cv = cv, let mapper = mapper {
            let dispatch = mapper.map(dispatch: self.store.dispatch)
            let next = mapper.map(state: state)
          
            if first || !Mapper.compareState(lhs: previous, rhs: next) {
              cv.variableProps = VariablePropsCt(first, previous, next, dispatch)
              previous = next
              first = false
            }
          }
        }
    }
    
    cv.staticProps = StaticPropsCt(self, unsubscribe)
    return unsubscribe
  }
  
  @discardableResult
  public func injectProps<VC, Mapper>(controller vc: VC, mapper: Mapper)
    -> ReduxUnsubscribe where
    VC: UIViewController,
    VC: ReduxCompatibleViewType,
    VC.PropsConnector == ReduxInjector,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == VC.StateProps,
    Mapper.DispatchProps == VC.DispatchProps
  {
    let cancel = self.injectProps(compatibleView: vc, mapper: mapper)
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = cancel
    vc.addChild(lifecycleVC)
    return cancel
  }
  
  @discardableResult
  public func injectProps<V, Mapper>(view: V, mapper: Mapper)
    -> ReduxUnsubscribe where
    V: UIView,
    V: ReduxCompatibleViewType,
    V.PropsConnector == ReduxInjector,
    Mapper: ReduxPropMapperType,
    Mapper.ReduxState == State,
    Mapper.StateProps == V.StateProps,
    Mapper.DispatchProps == V.DispatchProps
  {
    let cancel = self.injectProps(compatibleView: view, mapper: mapper)
    let lifecycleView = LifecycleView()
    lifecycleView.onDeinit = cancel
    view.addSubview(lifecycleView)
    return cancel
  }
}

extension ReduxInjector {
  final class LifecycleViewController: UIViewController {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }

  final class LifecycleView: UIView {
    deinit { self.onDeinit?() }
    var onDeinit: (() -> Void)?
  }
}
