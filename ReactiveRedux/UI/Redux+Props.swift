//
//  Redux+UI.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.UI {

  /// Static props container.
  public struct StaticProps<PropInjector: ReduxPropInjectorType> {
    
    /// The injector instance used to inject redux props into compatible views.
    public let injector: PropInjector
    
    /// Remember to unsubscribe before re-injecting again.
    let subscription: Redux.Store.Subscription
    
    init(_ injector: PropInjector, _ subscription: Redux.Store.Subscription) {
      self.injector = injector
      self.subscription = subscription
    }
  }
  
  /// Variable props container.
  public struct VariableProps<StateProps, ActionProps> {
    
    /// True if this is the first prop event.
    public let firstInstance: Bool
    
    /// The previous state props.
    public let previousState: StateProps?
    
    /// The next state props.
    public let nextState: StateProps
    
    /// Props to store redux actions.
    public let action: ActionProps
    
    init(_ firstInstance: Bool,
         _ previousState: StateProps?,
         _ nextState: StateProps,
         _ action: ActionProps) {
      self.firstInstance = firstInstance
      self.previousState = previousState
      self.nextState = nextState
      self.action = action
    }
  }
}
