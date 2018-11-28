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
  private var connector: ReduxConnector<Store>!
  private var mapper: ConnectMapper!
  
  override public func setUp() {
    super.setUp()
    self.store = ReduxUITests.Store()
    self.connector = ReduxConnector(store: store)
    self.mapper = ConnectMapper()
  }
}

public extension ReduxUITests {
  public func test_connectReduxView_shouldStreamState<View>(
    _ view: View,
    _ connect: (View) -> ReduxUnsubscribe,
    _ checkOthers: @escaping (View) -> Void) where
    View: ReduxCompatibleViewType,
    View.StateProps == Store.State,
    View.DispatchProps == () -> Void
  {
    /// Setup
    let iterations = 100
    
    /// When
    let cancel = connect(view)
    
    (0..<iterations).forEach({_ in
      self.store.lastState = Try.success(Store.State())
    })
    
    cancel()
    
    (0..<iterations).forEach({_ in
      self.store.lastState = Try.success(Store.State())
    })
    
    /// Then
    DispatchQueue.main.async {
      XCTAssertTrue(view.staticProps?.connector is ReduxConnector<Store>)
      XCTAssertEqual(self.store.cancelCount, 1)
      XCTAssertEqual(self.mapper.mapStateCount, iterations)
      XCTAssertEqual(self.mapper.mapDispatchCount, 1)
      XCTAssertFalse(ConnectMapper.compareState(lhs: Store.State(), rhs: Store.State()))
      checkOthers(view)
    }
  }
  
  public func test_connectViewController_shouldStreamState() {
    /// Setup
    let vc = ViewController()
    
    /// When && Then
    self.test_connectReduxView_shouldStreamState(
      vc,
      {self.connector.connect(controller: $0, mapper: self.mapper)},
      {XCTAssertEqual($0.setPropCount, self.mapper.mapStateCount)})
  }
  
  public func test_connectView_shouldStreamState() {
    /// Setup
    let view = View()

    /// When && Then
    self.test_connectReduxView_shouldStreamState(
      view,
      {self.connector.connect(view: $0, mapper: self.mapper)},
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
    
    public var lastState: Try<ReduxUITests.Store.State> {
      didSet {
        self.subscribers.forEach({(_, value) in _ = self.lastState.map(value)})
      }
    }
    
    private lazy var subscribers: [String : (State) -> Void] = [:]
    public lazy var cancelCount: Int = 0
    
    init() {
      self.lastState = Try.failure("")
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
    public var staticProps: StaticProps? {
      didSet {self.staticProps?.dispatch?()}
    }
    
    public var variableProps: VariableProps? {
      didSet {self.setPropCount += 1}
    }
    
    public var setPropCount = 0
  }
  
  public final class View: UIView {
    public var staticProps: StaticProps? {
      didSet {self.staticProps?.dispatch?()}
    }
    
    public var variableProps: VariableProps? {
      didSet {self.setPropCount += 1}
    }
    
    public var setPropCount = 0
  }
}

extension ReduxUITests {
  public final class ConnectMapper: ReduxPropMapperType {
    public typealias State = ReduxUITests.Store.State
    public typealias StateProps = State
    public typealias DispatchProps = () -> Void
    
    public var mapStateCount = 0
    public var mapDispatchCount = 0
    
    public func map(state: State) -> StateProps? {
      self.mapStateCount += 1
      return state
    }
    
    public func map(dispatch: @escaping ReduxDispatch) -> DispatchProps? {
      self.mapDispatchCount += 1
      return {dispatch(DefaultRedux.Action.noop)}
    }
  }
}

extension ReduxUITests.ViewController: ReduxCompatibleViewType {
  public typealias PropsConnector = ReduxConnector<ReduxUITests.Store>
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.View: ReduxCompatibleViewType {
  public typealias PropsConnector = ReduxConnector<ReduxUITests.Store>
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}
