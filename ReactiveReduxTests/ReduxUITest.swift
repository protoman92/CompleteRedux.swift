//
//  ReduxUITest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
import UIKit
import XCTest
@testable import ReactiveRedux

public final class ReduxUITests: XCTestCase {
  private var store: Store!
  private var injector: Redux.PropInjector<Store>!
  private let iterations = 100
  
  override public func setUp() {
    super.setUp()
    self.store = ReduxUITests.Store()
    self.injector = Redux.PropInjector(store: store)
  }
}

public extension ReduxUITests {
  public func test_injectReduxView_shouldStreamState<View>(
    _ view: View,
    _ inject: @escaping (View) -> Redux.Subscription,
    _ checkOthers: @escaping (View) -> Void) where
    View: ReduxCompatibleViewType,
    View.StateProps == State,
    View.DispatchProps == () -> Void
  {
    /// Setup
    let subscription = inject(view)
    
    /// When
    (0..<self.iterations).forEach({_ in self.store.lastState = .init()})
    subscription.unsubscribe()
    (0..<self.iterations).forEach({_ in self.store.lastState = .init()})
    
    /// Then
    XCTAssertEqual(self.store.unsubscribeCount, 1)
    
    DispatchQueue.main.async {
      XCTAssertTrue(view.staticProps?.injector is Redux.PropInjector<Store>)
      checkOthers(view)
      
      // Check if re-injecting would unsubscribe from the previous subscription.
      _ = inject(view)
      XCTAssertEqual(self.store.unsubscribeCount, 2)
    }
  }
  
  public func test_injectViewController_shouldStreamState() {
    /// Setup
    let vc = ViewController()
    
    /// When && Then
    self.test_injectReduxView_shouldStreamState(vc,
      {self.injector.injectProps(controller: $0, outProps: 0)},
      {XCTAssertEqual($0.setPropCount, self.iterations)})
    
    XCTAssertFalse(ViewController.compareState(lhs: State(), rhs: State()))
  }
  
  public func test_injectingView_shouldStreamState() {
    /// Setup
    let view = View()

    /// When && Then
    self.test_injectReduxView_shouldStreamState(view,
      {self.injector.injectProps(view: $0, outProps: 0)},
      {XCTAssertEqual($0.setPropCount, self.iterations)})
    
    XCTAssertFalse(View.compareState(lhs: State(), rhs: State()))
  }
}

public extension ReduxUITests {
  public struct State: Equatable {
    private static var counter = 0
    
    private let counter: Int
    
    public init() {
      State.counter += 1
      self.counter = State.counter
    }
  }
  
  public final class Store: ReduxStoreType {
    public var lastState: State {
      didSet {
        self.subscribers.forEach({(_, value) in _ = value(self.lastState)})
      }
    }
    
    private var subscribers = [String : Redux.StateCallback<State>]()
    public var unsubscribeCount: Int = 0
    
    init() {
      self.lastState = State()
    }
    
    public var dispatch: Redux.Dispatch {
      return {_ in}
    }
    
    public var subscribeState: Redux.Subscribe<State> {
      return {
        let subscriberId = $0
        self.subscribers[subscriberId] = $1
      
        return Redux.Subscription({
          self.unsubscribeCount += 1
          self.subscribers.removeValue(forKey: subscriberId)
        })
      }
    }
  }
}

public extension ReduxUITests {
  public final class ViewController: UIViewController {
    public var staticProps: StaticProps?
    
    public var variableProps: VariableProps? {
      didSet {
        self.setPropCount += 1
        self.variableProps?.dispatch()
      }
    }
    
    public var setPropCount = 0
  }
  
  public final class View: UIView {
    public var staticProps: StaticProps?
    
    public var variableProps: VariableProps? {
      didSet {
        self.setPropCount += 1
        self.variableProps?.dispatch()
      }
    }
    
    public var setPropCount = 0
  }
}

extension ReduxUITests.ViewController: ReduxCompatibleViewType {
  public typealias PropInjector = Redux.PropInjector<ReduxUITests.Store>
  public typealias OutProps = Int
  public typealias StateProps = ReduxUITests.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.ViewController: ReduxPropMapperType {
  public typealias ReduxState = ReduxUITests.State
  
  public static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
  }
  
  public static func map(dispatch: @escaping Redux.Dispatch,
                         outProps: OutProps) -> DispatchProps {
    return {dispatch(Redux.DefaultAction.noop)}
  }
}

extension ReduxUITests.View: ReduxCompatibleViewType {
  public typealias PropInjector = Redux.PropInjector<ReduxUITests.Store>
  public typealias OutProps = Int
  public typealias StateProps = ReduxUITests.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.View: ReduxPropMapperType {
  public typealias ReduxState = ReduxUITests.State
  
  public static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
  }
  
  public static func map(dispatch: @escaping Redux.Dispatch,
                         outProps: OutProps) -> DispatchProps {
    return {dispatch(Redux.DefaultAction.noop)}
  }
}
