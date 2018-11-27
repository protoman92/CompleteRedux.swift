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
    let vc = ViewController()
    
    /// When
    self.reduxConnector.connect(viewController: vc)
    
    /// Then
    XCTAssertEqual(ViewController.mapStateToPropsCount, 0)
    XCTAssertEqual(ViewController.mapDispatchToPropsCount, 1)
  }
}

public extension ReduxUITests {
  public final class Store {
    public struct State {}
    
    public lazy var lastState: Try<ReduxUITests.Store.State> = Try.failure("")
  }
  
  public final class ViewController: UIViewController {
    public var reduxProps: ReduxProps? {
      didSet {
        self.setPropCount += 1
      }
    }
    
    public static var mapStateToPropsCount = 0
    public static var mapDispatchToPropsCount = 0
    public var setPropCount = 0
  }
}

extension ReduxUITests.Store: ReduxStoreType {
  public func dispatch(_ action: ReduxActionType) {}
  
  public func subscribeState<SS>(selector: @escaping (State) -> SS,
                                 comparer: @escaping (SS, SS) -> Bool,
                                 callback: @escaping (SS) -> Void) -> Cancellable {
    return {}
  }
}

extension ReduxUITests.Store.State: Equatable {}

extension ReduxUITests.ViewController: ReduxConnectableView {
  public typealias State = ReduxUITests.Store.State
  public typealias StateProps = State
  public typealias DispatchProps = ()
  
  public static func mapStateToProps(state: State) -> StateProps {
    self.mapStateToPropsCount += 1
    return state
  }
  
  public static func mapDispatchToProps(dispatch: @escaping ReduxDispatch) -> DispatchProps {
    self.mapDispatchToPropsCount += 1
    return ()
  }
}
