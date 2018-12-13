//
//  Redux+UI.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.UI {

  /// Static props container.
  public class StaticProps<State> {
    
    /// The injector instance used to inject Redux props into compatible views.
    public let injector: Redux.UI.PropInjector<State>
    
    /// Remember to unsubscribe before re-injecting again.
    let subscription: Redux.Store.Subscription
    
    internal init(_ injector: Redux.UI.PropInjector<State>,
                  _ subscription: Redux.Store.Subscription) {
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
    
    /// Props to store Redux actions.
    public let action: ActionProps
    
    public init(firstInstance: Bool = false,
                previousState: StateProps? = nil,
                nextState: StateProps,
                action: ActionProps) {
      self.firstInstance = firstInstance
      self.previousState = previousState
      self.nextState = nextState
      self.action = action
    }
  }
}
