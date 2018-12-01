//
//  Redux.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 11/22/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import SafeNest

extension UIViewController {
  typealias PropInjector = Redux.PropInjector<Redux.RxStore<SafeNest>>
}

extension UIView {
  typealias PropInjector = Redux.PropInjector<Redux.RxStore<SafeNest>>
}

final class AppRedux {
  typealias Action = ReduxActionType
  typealias State = SafeNest
  
  final class Path {
    static let rootPath = "main"
    static let numberPath = "\(Path.rootPath).number"
    static let stringPath = "\(Path.rootPath).string"
    static let sliderPath = "\(Path.rootPath).slider"
    static let textIndexesPath = "\(Path.rootPath).textIndexes"
    static let textPath = "\(Path.rootPath).texts"
    
    static func textItemPath(_ textIndex: Int) -> String {
      return "\(textPath).\(textIndex)"
    }
  }
  
  enum ClearAction: ReduxActionType {
    case triggerClear
  }
  
  enum NumberAction: Action {
    case add
    case minus
  }
  
  enum StringAction: Action {
    case input(String?)
  }
  
  enum SliderAction: Action {
    case input(Double)
  }
  
  enum TextAction: Action {
    case addItem
    case input(Int, String?)
    case delete(Int)
  }
  
  final class Reducer {
    static func main(_ state: State, _ action: Action) -> SafeNest {
      do {
        switch action {
        case let action as ClearAction: return try clear(state, action)
        case let action as NumberAction: return try number(state, action)
        case let action as StringAction: return try string(state, action)
        case let action as SliderAction: return try slider(state, action)
        case let action as TextAction: return try text(state, action)
        default: return state
        }
      } catch (let e) {
        fatalError(e.localizedDescription)
      }
    }
    
    static func clear(_ state: State, _ action: ClearAction) throws -> State {
      switch action {
      case .triggerClear:
        return try state.updating(at: Path.rootPath, value: nil)
      }
    }
    
    static func number(_ state: State, _ action: NumberAction) throws -> State {
      switch action {
      case .add:
        return try state.mapping(at: Path.numberPath, withMapper: {
          return $0.cast(Int.self).getOrElse(0) + 1
        })
        
      case .minus:
        return try state.mapping(at: Path.numberPath, withMapper: {
          return $0.cast(Int.self).getOrElse(0) - 1
        })
      }
    }
    
    static func string(_ state: State, _ action: StringAction) throws -> State {
      switch action {
      case .input(let string):
        return try state.updating(at: Path.stringPath, value: string)
      }
    }
    
    static func slider(_ state: State, _ action: SliderAction) throws -> State {
      switch action {
      case .input(let value):
        return try state.updating(at: Path.sliderPath, value: value)
      }
    }
    
    static func text(_ state: State, _ action: TextAction) throws -> State {
      switch action {
      case .addItem:
        let mapper: State.TypedMapper<[Int], [Int]> = {
          $0.getOrElse([]) + ($0?.last).map({[$0 + 1]}).getOrElse([0])
        }
        
        return try state.mapping(at: Path.textIndexesPath, withMapper: mapper)
        
      case .input(let index, let value):
        return try state.updating(at: Path.textItemPath(index), value: value)
        
      case .delete(let index):
        let mapper: State.TypedMapper<[Int], [Int]> = {
          var copy = $0
          copy?.remove(at: index)
          return copy
        }
        
        return try state.mapping(at: Path.textIndexesPath, withMapper: mapper)
      }
    }
  }
}
