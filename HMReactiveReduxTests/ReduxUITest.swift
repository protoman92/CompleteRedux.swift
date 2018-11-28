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
  private var reduxConnector: ReduxConnector<Store>!
  private var deepConnector: DeepConnector!
  private var mapper: ConnectMapper!
  
  override public func setUp() {
    super.setUp()
    self.store = ReduxUITests.Store()
    self.reduxConnector = ReduxConnector(store: store)
    self.mapper = ConnectMapper()
    
    self.deepConnector = DeepConnector(connector: self.reduxConnector!,
                                       mapper: self.mapper!)
  }
}

public extension ReduxUITests {
  public func test_connectReduxView_shouldStreamState<View>(
    _ view: View,
    _ connect: (View) -> Store.Cancellable) where
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
    XCTAssertEqual(self.store.cancelCount, 1)
    XCTAssertEqual(self.mapper.mapStateCount, iterations)
    XCTAssertEqual(self.mapper.mapDispatchCount, 1)
    XCTAssertTrue(ConnectMapper.compareState(lhs: Store.State(), rhs: Store.State()))
  }
  
  public func test_connectViewController_shouldStreamState() {
    /// Setup
    let vc = ViewController()
    
    /// When
    test_connectReduxView_shouldStreamState(vc) {
      self.deepConnector.connectDeeply(controller: $0)!
    }
    
    /// Then
    XCTAssertEqual(vc.setPropCount, self.mapper.mapStateCount)
  }
  
  public func test_connectView_shouldStreamState() {
    /// Setup
    let view = View()

    /// When
    test_connectReduxView_shouldStreamState(view) {
      self.deepConnector.connectDeeply(view: $0)!
    }

    /// Then
    XCTAssertEqual(view.setPropCount, self.mapper.mapStateCount)
  }
}

public extension ReduxUITests {
  public final class Store: ReduxStoreType {
    public struct State {}
    
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
    
    public func subscribeState<SS>(subscriberId: String,
                                   selector: @escaping (State) -> SS,
                                   comparer: @escaping (SS, SS) -> Bool,
                                   callback: @escaping (SS) -> Void) -> Cancellable {
      self.subscribers[subscriberId] = {callback(selector($0))}
      
      return {
        self.cancelCount += 1
        self.subscribers.removeValue(forKey: subscriberId)
      }
    }
  }
}

public extension ReduxUITests {
  public final class ViewController: UIViewController {
    public var reduxProps: Props? {
      didSet {
        self.setPropCount += 1
        self.reduxProps?.dispatch?()
      }
    }
    
    public var setPropCount = 0
  }
  
  public final class View: UIView {
    public var reduxProps: Props? {
      didSet {
        self.setPropCount += 1
        self.reduxProps?.dispatch?()
      }
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
  
  public final class DeepConnector: ReduxDeepConnectorType {
    public typealias Connector = ReduxConnector<Store>
    
    private let connector: Connector
    private let mapper: ConnectMapper
    
    public init(connector: Connector, mapper: ConnectMapper) {
      self.connector = connector
      self.mapper = mapper
    }
    
    public func connect(controller vc: UIViewController) -> Store.Cancellable? {
      let vc = vc as! ViewController
      return self.connector.connect(controller: vc, mapper: self.mapper)
    }
    
    public func connect(view: UIView) -> Store.Cancellable? {
      let view = view as! View
      return self.connector.connect(view: view, mapper: self.mapper)
    }
  }
}

extension ReduxUITests.ViewController: ReduxCompatibleViewType {
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.View: ReduxCompatibleViewType {
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.Store.State: Equatable {}
