//
//  ReduxAction.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
import SwiftUtilities
@testable import HMReactiveRedux

public enum Action: ReduxActionType, EnumerableType {
  case add
  case addTwo
  case addThree
  case minus

  public static func allValues() -> [Action] {
    return [add, addTwo, addThree, minus]
  }

  public func updateFn() -> (Int) -> Int {
    switch self {
    case .add: return {$0 + 1}
    case .addTwo: return {$0 + 2}
    case .addThree: return {$0 + 3}
    case .minus: return {$0 - 1}
    }
  }

  public func treeStateUpdateFn() -> TreeState<Int>.UpdateFn {
    switch self {
    case .add: return {$0.map({$0 + 1})}
    case .addTwo: return {$0.map({$0 + 2})}
    case .addThree: return {$0.map({$0 + 3})}
    case .minus: return {$0.map({$0 - 1})}
    }
  }
}
