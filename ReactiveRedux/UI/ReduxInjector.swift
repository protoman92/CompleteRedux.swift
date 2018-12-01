//
//  ReduxInjector.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Inject views with state/dispatch props, similar to how React.js performs
/// connect.
public protocol ReduxPropInjectorType {
  associatedtype State
  
  /// Inject state/dispatch props into a compatible view controller.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - outProps: An OutProps instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  func injectProps<VC, MP>(controller: VC, outProps: VC.OutProps, mapper: MP.Type)
    -> ReduxSubscription where
    VC: UIViewController,
    VC.PropInjector == Self,
    MP: ReduxPropMapperType,
    MP.ReduxState == State,
    MP.ReduxView == VC
  
  /// Inject state/dispatch props into a compatible view.
  ///
  /// - Parameters:
  ///   - view: A view instance.
  ///   - outProps: An OutProps instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  func injectProps<V, MP>(view: V, outProps: V.OutProps, mapper: MP.Type)
    -> ReduxSubscription where
    V: UIView,
    V.PropInjector == Self,
    MP: ReduxPropMapperType,
    MP.ReduxState == State,
    MP.ReduxView == V
}

public extension ReduxPropInjectorType {
  
  /// Convenience method to inject props when the controller also conforms to
  /// the necessary protocols.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  public func injectProps<VC>(controller vc: VC, outProps: VC.OutProps)
    -> ReduxSubscription where
    VC: UIViewController,
    VC: ReduxPropMapperType,
    VC.PropInjector == Self,
    VC.ReduxState == State,
    VC.ReduxView == VC
  {
    return self.injectProps(controller: vc, outProps: outProps, mapper: VC.self)
  }
  
  /// Convenience method to inject props when the view also conforms to the
  /// necessary protocols.
  ///
  /// - Parameters:
  ///   - view: A view instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  public func injectProps<V>(view: V, outProps: V.OutProps)
    -> ReduxSubscription where
    V: UIView,
    V: ReduxPropMapperType,
    V.PropInjector == Self,
    V.ReduxState == State,
    V.ReduxView == V
  {
    return self.injectProps(view: view, outProps: outProps, mapper: V.self)
  }
}


/// Basic redux injector implementation that also handles view lifecycles.
public struct ReduxInjector<Store: ReduxStoreType>: ReduxPropInjectorType {
  public typealias State = Store.State
  private let store: Store
  
  public init(store: Store) {
    self.store = store
  }
  
  func injectProps<CV, MP>(_ cv: CV, _ outProps: CV.OutProps, _ mapper: MP.Type)
    -> ReduxSubscription where
    CV.PropInjector == ReduxInjector,
    MP: ReduxPropMapperType,
    MP.ReduxState == State,
    MP.ReduxView == CV
  {
    let dispatch = self.store.dispatch
    
    // Here we use the view's class name and a timestamp as the subscription
    // id. We don't even need to store this id because we can simply cancel
    // with the returned subscription callback (so the id can be literally
    // anything, as long as it is unique).
    let timestamp = Date().timeIntervalSince1970
    let viewId = String(describing: cv) + String(describing: timestamp)
    var previous: CV.StateProps? = nil
    var first = true
    
    // If there has been a previous subscription, unsubscribe from it to avoid
    // having parallel subscriptions.
    cv.staticProps?.subscription.unsubscribe()
    
    let unsubscribe = self.store
      .subscribeState(subscriberId: viewId) {[weak cv] state in
        // Since UI operations must happen on the main thread, we dispatch with
        // the main queue. Setting the previous props here is ok as well since
        // only the main queue is accessing it.
        DispatchQueue.main.async {
          let dispatch = MP.map(dispatch: dispatch, outProps: outProps)
          let next = MP.map(state: state, outProps: outProps)
        
          if first || !MP.compareState(lhs: previous, rhs: next) {
            cv?.variableProps = VariablePropsCt(first, previous, next, dispatch)
            previous = next
            first = false
          }
        }
    }
    
    cv.staticProps = StaticPropsCt(self, unsubscribe)
    return unsubscribe
  }
  
  @discardableResult
  public func injectProps<VC, MP>(controller: VC, outProps: VC.OutProps, mapper: MP.Type)
    -> ReduxSubscription where
    VC: UIViewController,
    VC.PropInjector == ReduxInjector,
    MP: ReduxPropMapperType,
    MP.ReduxState == State,
    MP.ReduxView == VC
  {
    let subscription = self.injectProps(controller, outProps, mapper)
    let lifecycleVC = LifecycleViewController()
    lifecycleVC.onDeinit = subscription.unsubscribe
    controller.addChild(lifecycleVC)
    return subscription
  }
  
  @discardableResult
  public func injectProps<V, MP>(view: V, outProps: V.OutProps, mapper: MP.Type)
    -> ReduxSubscription where
    V: UIView,
    V.PropInjector == ReduxInjector,
    MP: ReduxPropMapperType,
    MP.ReduxState == State,
    MP.ReduxView == V
  {
    let subscription = self.injectProps(view, outProps, mapper)
    let lifecycleView = LifecycleView()
    lifecycleView.onDeinit = subscription.unsubscribe
    view.addSubview(lifecycleView)
    return subscription
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
