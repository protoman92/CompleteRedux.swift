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
  private var mapper: PropMapper!
  
  override public func setUp() {
    super.setUp()
    self.store = ReduxUITests.Store()
    self.injector = ReduxInjector(store: store)
    self.mapper = PropMapper()
  }
}

public extension ReduxUITests {
  public func test_injectReduxView_shouldStreamState<View>(
    _ view: View,
    _ inject: @escaping (View) -> ReduxUnsubscribe,
    _ checkOthers: @escaping (View) -> Void) where
    View: ReduxCompatibleViewType,
    View.StateProps == Store.State,
    View.DispatchProps == () -> Void
  {
    /// Setup
    let iterations = 100
    
    /// When
    let unsubscribe = inject(view)
    
    (0..<iterations).forEach({_ in self.store.lastState = .init()})
    unsubscribe()
    (0..<iterations).forEach({_ in self.store.lastState = .init()})
    
    /// Then
    XCTAssertEqual(self.store.cancelCount, 1)
    
    DispatchQueue.main.async {
      XCTAssertTrue(view.staticProps?.injector is ReduxInjector<Store>)
      XCTAssertEqual(self.mapper.mapStateCount, iterations)
      XCTAssertEqual(self.mapper.mapDispatchCount, iterations)
      XCTAssertFalse(PropMapper.compareState(lhs: Store.State(), rhs: Store.State()))
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
    self.test_injectReduxView_shouldStreamState(
      vc,
      {self.injector.injectProps(controller: $0, mapper: self.mapper)},
      {XCTAssertEqual($0.setPropCount, self.mapper.mapStateCount)})
  }
  
  public func test_injectingView_shouldStreamState() {
    /// Setup
    let view = View()

    /// When && Then
    self.test_injectReduxView_shouldStreamState(
      view,
      {self.injector.injectProps(view: $0, mapper: self.mapper)},
      {XCTAssertEqual($0.setPropCount, self.mapper.mapStateCount)})
  }
}

public extension ReduxUITests {
  public final class Store: ReduxStoreType {
    public struct State: Equatable {
      private static var counter = 0
      
      private let counter: Int
      
      public init() {
        State.counter += 1
        self.counter = State.counter
      }
    }
    
    public var lastState: ReduxUITests.Store.State {
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

extension ReduxUITests {
  public final class PropMapper: ReduxPropMapperType {
    public typealias ReduxState = ReduxUITests.Store.State
    public typealias StateProps = ReduxState
    public typealias DispatchProps = () -> Void
    
    public var mapStateCount = 0
    public var mapDispatchCount = 0
    
    public func map(state: ReduxState) -> StateProps {
      self.mapStateCount += 1
      return state
    }
    
    public func map(dispatch: @escaping ReduxDispatch) -> DispatchProps {
      self.mapDispatchCount += 1
      return {dispatch(DefaultRedux.Action.noop)}
    }
  }
}

extension ReduxUITests.ViewController: ReduxCompatibleViewType {
  public typealias PropInjector = ReduxInjector<ReduxUITests.Store>
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.View: ReduxCompatibleViewType {
  public typealias PropInjector = ReduxInjector<ReduxUITests.Store>
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}
