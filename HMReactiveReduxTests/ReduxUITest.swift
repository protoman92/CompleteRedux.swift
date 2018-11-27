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
  
  override public func setUp() {
    super.setUp()
    ConnectMapper.mapStateToPropsCount = 0
    ConnectMapper.mapDispatchToPropsCount = 0
    self.store = ReduxUITests.Store()
    self.reduxConnector = ReduxConnector(store: store)
  }
}

public extension ReduxUITests {
  public func test_connectViewController_shouldStreamState() {
    /// Setup
    let iterations = 100
    let vc = ViewController()
    
    /// When
    let cancel = self.reduxConnector.connect(viewController: vc,
                                             mapper: ConnectMapper.self)
    
    (0..<iterations).forEach({_ in
      self.store.lastState = Try.success(Store.State())
    })
    
    cancel()
    
    (0..<iterations).forEach({_ in
      self.store.lastState = Try.success(Store.State())
    })
    
    /// Then
    XCTAssertEqual(ConnectMapper.mapStateToPropsCount, iterations)
    XCTAssertEqual(ConnectMapper.mapDispatchToPropsCount, 1)
    XCTAssertEqual(vc.setPropCount, iterations)
    XCTAssertTrue(ConnectMapper.compareState(lhs: Store.State(), rhs: Store.State()))
  }
}

public extension ReduxUITests {
  public final class Store {
    public struct State {}
    
    public var lastState: Try<ReduxUITests.Store.State> {
      didSet {
        self.subscribers.forEach({(_, value) in _ = self.lastState.map(value)})
      }
    }
    
    private lazy var subscribers: [String : (State) -> Void] = [:]
    
    init() {
      self.lastState = Try.failure("")
    }
  }
  
  public final class ViewController: UIViewController {
    public var reduxProps: ReduxProps? {
      didSet {
        self.setPropCount += 1
        self.reduxProps?.dispatch()
      }
    }
    
    public var setPropCount = 0
  }
  
  public final class ConnectMapper {
    public static var mapStateToPropsCount = 0
    public static var mapDispatchToPropsCount = 0
  }
}

extension ReduxUITests.Store: ReduxStoreType {
  public func dispatch(_ action: ReduxActionType) {}
  
  public func subscribeState<SS>(subscriberId: String,
                                 selector: @escaping (State) -> SS,
                                 comparer: @escaping (SS, SS) -> Bool,
                                 callback: @escaping (SS) -> Void) -> Cancellable {
    self.subscribers[subscriberId] = {callback(selector($0))}
    return {self.subscribers.removeValue(forKey: subscriberId)}
  }
}

extension ReduxUITests.ViewController: ReduxConnectableView {
  public typealias StateProps = ReduxUITests.Store.State
  public typealias DispatchProps = () -> Void
}

extension ReduxUITests.ConnectMapper: ReduxConnectorMapper {
  public typealias State = ReduxUITests.Store.State
  public typealias View = ReduxUITests.ViewController
  
  public static func map(state: State) -> View.StateProps {
    self.mapStateToPropsCount += 1
    return state
  }
  
  public static func map(dispatch: @escaping ReduxDispatch) -> View.DispatchProps {
    self.mapDispatchToPropsCount += 1
    return {dispatch(DefaultRedux.Action.noop)}
  }
}

extension ReduxUITests.Store.State: Equatable {}
