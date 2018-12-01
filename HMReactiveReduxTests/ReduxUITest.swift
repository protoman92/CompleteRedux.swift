//
//  ReduxUITest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP
import UIKit
import XCTest
@testable import HMReactiveRedux

public final class ReduxUITests: XCTestCase {
  private var store: Store!
  private var injector: ReduxInjector<Store>!
  private let iterations = 100
  
  override public func setUp() {
    super.setUp()
    self.store = ReduxUITests.Store()
    self.injector = ReduxInjector(store: store)
  }
}

public extension ReduxUITests {
  public func test_injectReduxView_shouldStreamState<View>(
    _ view: View,
    _ inject: @escaping (View) -> ReduxUnsubscribe,
    _ checkOthers: @escaping (View) -> Void) where
    View: ReduxCompatibleViewType,
    View.StateProps == State,
    View.DispatchProps == () -> Void
  {
    /// Setup
    let unsubscribe = inject(view)
    
    /// When
    (0..<self.iterations).forEach({_ in self.store.lastState = .init()})
    unsubscribe()
    (0..<self.iterations).forEach({_ in self.store.lastState = .init()})
    
    /// Then
    XCTAssertEqual(self.store.cancelCount, 1)
    
    DispatchQueue.main.async {
      XCTAssertTrue(view.staticProps?.injector is ReduxInjector<Store>)
      checkOthers(view)
      
      // Check if re-injecting would unsubscribe from the previous subscription.
      _ = inject(view)
      XCTAssertEqual(self.store.cancelCount, 2)
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
    
    private lazy var subscribers: [String : (State) -> Void] = [:]
    public lazy var cancelCount: Int = 0
    
    init() {
      self.lastState = State()
    }
    
    public func dispatch(_ action: ReduxActionType) {}
    
    public func subscribeState(subscriberId: String,
                               callback: @escaping (State) -> Void)
      -> ReduxUnsubscribe
    {
      self.subscribers[subscriberId] = callback
      
      return {
        self.cancelCount += 1
        self.subscribers.removeValue(forKey: subscriberId)
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
  public typealias PropInjector = ReduxInjector<ReduxUITests.Store>
  public typealias OutProps = Int
  public typealias StateProps = ReduxUITests.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.ViewController: ReduxPropMapperType {
  public typealias ReduxState = ReduxUITests.State
  
  public static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
  }
  
  public static func map(dispatch: @escaping ReduxDispatch,
                         outProps: OutProps) -> DispatchProps {
    return {dispatch(DefaultRedux.Action.noop)}
  }
}

extension ReduxUITests.View: ReduxCompatibleViewType {
  public typealias PropInjector = ReduxInjector<ReduxUITests.Store>
  public typealias OutProps = Int
  public typealias StateProps = ReduxUITests.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.View: ReduxPropMapperType {
  public typealias ReduxState = ReduxUITests.State
  
  public static func map(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
  }
  
  public static func map(dispatch: @escaping ReduxDispatch,
                         outProps: OutProps) -> DispatchProps {
    return {dispatch(DefaultRedux.Action.noop)}
  }
}
