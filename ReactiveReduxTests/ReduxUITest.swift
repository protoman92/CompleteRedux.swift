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

final class ReduxUITests: XCTestCase {
  private var store: Store!
  private var injector: Redux.UI.PropInjector<State>!
  private let iterations = 100
  
  override func setUp() {
    super.setUp()
    State.counter = -1
    self.store = ReduxUITests.Store()
    self.injector = Redux.UI.PropInjector(store: self.store)
  }
}

extension ReduxUITests {
  func test_injectReduxView_shouldStreamState<View>(
    _ view: View,
    _ inject: @escaping (View) -> Redux.Store.Subscription,
    _ checkOthers: @escaping (View) -> Void) where
    View: ReduxCompatibleViewType,
    View.StateProps == State,
    View.ActionProps == () -> Void
  {
    /// Setup
    let subscription = inject(view)
    
    /// When
    (0..<self.iterations).forEach({_ in self.store.state = .init()})
    subscription.unsubscribe()
    (0..<self.iterations).forEach({_ in self.store.state = .init()})
    
    /// Then
    XCTAssertEqual(self.store.lastState().counter, self.iterations * 2)
    XCTAssertEqual(self.store.unsubscribeCount, 1)
    
    DispatchQueue.main.async {
      XCTAssertTrue(view.staticProps?.injector is Redux.UI.PropInjector<State>)
      checkOthers(view)
      
      // Check if re-injecting would unsubscribe from the previous subscription.
      _ = inject(view)
      XCTAssertEqual(self.store.unsubscribeCount, 2)
    }
  }
  
  func test_injectViewController_shouldStreamState() {
    /// Setup
    let vc = ViewController()
    
    /// When && Then
    self.test_injectReduxView_shouldStreamState(vc,
      {self.injector.injectProps(controller: $0, outProps: 0)},
      {XCTAssertEqual($0.setPropCount, self.iterations + 1)})
    
    XCTAssertFalse(ViewController.compareState(lhs: State(), rhs: State()))
  }
  
  func test_injectingView_shouldStreamState() {
    /// Setup
    let view = View()

    /// When && Then
    self.test_injectReduxView_shouldStreamState(view,
      {self.injector.injectProps(view: $0, outProps: 0)},
      {XCTAssertEqual($0.setPropCount, self.iterations + 1)})
    
    XCTAssertFalse(View.compareState(lhs: State(), rhs: State()))
  }
}

extension ReduxUITests {
  struct State: Equatable {
    static var counter = -1
    
    let counter: Int
    
    init() {
      State.counter += 1
      self.counter = State.counter
    }
  }
  
  final class Store: ReduxStoreType {
    var state: State {
      didSet {
        self.subscribers.forEach({(_, value) in _ = value(self.state)})
      }
    }
    
    private var subscribers = [String : Redux.Store.StateCallback<State>]()
    var unsubscribeCount: Int = 0
    
    init() {
      self.state = State()
    }
    
    var lastState: Redux.Store.LastState<State> {
      return {self.state}
    }
    
    var dispatch: Redux.Store.Dispatch {
      return {_ in}
    }
    
    var subscribeState: Redux.Store.Subscribe<State> {
      return {
        let subscriberId = $0
        self.subscribers[subscriberId] = $1
      
        return Redux.Store.Subscription({
          self.unsubscribeCount += 1
          self.subscribers.removeValue(forKey: subscriberId)
        })
      }
    }
  }
}

extension ReduxUITests {
  final class ViewController: UIViewController {
    var staticProps: StaticProps?
    
    var variableProps: VariableProps? {
      didSet {
        self.setPropCount += 1
        self.variableProps?.action()
      }
    }
    
    var setPropCount = 0
  }
  
  final class View: UIView {
    var staticProps: StaticProps?
    
    var variableProps: VariableProps? {
      didSet {
        self.setPropCount += 1
        self.variableProps?.action()
      }
    }
    
    var setPropCount = 0
  }
}

extension ReduxUITests.ViewController: ReduxCompatibleViewType {
  typealias ReduxState = ReduxUITests.State
  typealias OutProps = Int
  typealias StateProps = ReduxUITests.State
  typealias ActionProps = () -> Void
}

extension ReduxUITests.ViewController: ReduxPropMapperType {
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
  }
  
  static func mapAction(dispatch: @escaping Redux.Store.Dispatch,
                        outProps: OutProps) -> ActionProps {
    return {dispatch(Redux.Preset.Action.noop)}
  }
}

extension ReduxUITests.View: ReduxCompatibleViewType {
  typealias ReduxState = ReduxUITests.State
  typealias OutProps = Int
  typealias StateProps = ReduxUITests.State
  typealias ActionProps = () -> Void
}

extension ReduxUITests.View: ReduxPropMapperType {
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps {
    return state
  }
  
  static func mapAction(dispatch: @escaping Redux.Store.Dispatch,
                        outProps: OutProps) -> ActionProps {
    return {dispatch(Redux.Preset.Action.noop)}
  }
}
