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
    ViewController.mapStateToPropsCount = 0
    ViewController.mapDispatchToPropsCount = 0
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
    let cancel = self.reduxConnector.connect(viewController: vc)
    
    (0..<iterations).forEach({_ in
      self.store.lastState = Try.success(Store.State())
    })
    
    cancel()
    
    (0..<iterations).forEach({_ in
      self.store.lastState = Try.success(Store.State())
    })
    
    /// Then
    XCTAssertEqual(ViewController.mapStateToPropsCount, iterations)
    XCTAssertEqual(ViewController.mapDispatchToPropsCount, 1)
    XCTAssertEqual(vc.setPropCount, iterations)
    XCTAssertTrue(ViewController.compareState(lhs: Store.State(), rhs: Store.State()))
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
    
    public static var mapStateToPropsCount = 0
    public static var mapDispatchToPropsCount = 0
    public var setPropCount = 0
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

extension ReduxUITests.Store.State: Equatable {}

extension ReduxUITests.ViewController: ReduxConnectableView {
  public typealias State = ReduxUITests.Store.State
  public typealias StateProps = State
  public typealias DispatchProps = () -> Void
  
  public static func mapStateToProps(state: State) -> StateProps {
    self.mapStateToPropsCount += 1
    return state
  }
  
  public static func mapDispatchToProps(dispatch: @escaping ReduxDispatch) -> DispatchProps {
    self.mapDispatchToPropsCount += 1
    return {dispatch(DefaultRedux.Action.noop)}
  }
}
