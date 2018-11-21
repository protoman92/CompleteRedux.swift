//
//  ViewController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import RxCocoa
import RxSwift
import SafeNest
import SwiftFP
import SwiftUtilities
import UIKit

public enum ClearAction: ReduxActionType {
  case triggerClear
  case resetClear
  
  public static var path: String {
    return "clear"
  }
  
  public static var clearPath: String {
    return "\(path).value"
  }
}

public enum NumberAction: ReduxActionType {
  case add
  case minus

  public static var rootPath: String {
    return "main.number"
  }

  public static var actionPath: String {
    return "\(rootPath).action"
  }

  public static var action2Path: String {
    return "\(rootPath).action2"
  }
}

public enum StringAction: ReduxActionType {
  case input(String)

  public static var rootPath: String {
    return "main.string"
  }

  public static var actionPath: String {
    return "\(rootPath).action"
  }
}

public enum SliderAction: ReduxActionType {
  case input(Double)

  public static var rootPath: String {
    return "main.slider"
  }

  public static var actionPath: String {
    return "\(rootPath).action"
  }
}

public func mainReducer(_ state: SafeNest, _ action: ReduxActionType) -> SafeNest {
  switch action {
  case let action as ClearAction: return clearReducer(state, action)
  case let action as NumberAction: return numberReducer(state, action)
  case let action as StringAction: return stringReducer(state, action)
  case let action as SliderAction: return sliderReducer(state, action)
  default: return state
  }
}

public func clearReducer(_ state: SafeNest, _ action: ClearAction) -> SafeNest {
  switch action {
  case .triggerClear:
    return try! state
      .updating(at: NumberAction.rootPath, value: nil)
      .updating(at: StringAction.rootPath, value: nil)
      .updating(at: SliderAction.rootPath, value: nil)
      .updating(at: ClearAction.clearPath, value: true)
    
  case .resetClear:
    return try! state.updating(at: ClearAction.clearPath, value: nil)
  }
}

public func numberReducer(_ state: SafeNest, _ action: NumberAction) -> SafeNest {
  let path = NumberAction.actionPath

  switch action {
  case .add:
    return try! state.mapping(at: path, withMapper: {
      return $0.cast(Int.self).someOrElse(Optional.some(0)).map({$0 + 1})
    })

  case .minus:
    return try! state.mapping(at: path, withMapper: {
      return $0.cast(Int.self).someOrElse(Optional.some(0)).map({$0 - 1})
    })
  }
}

public func stringReducer(_ state: SafeNest, _ action: StringAction) -> SafeNest {
  let path = StringAction.actionPath

  switch action {
  case .input(let string):
    return try! state.updating(at: path, value: string)
  }
}

public func sliderReducer(_ state: SafeNest, _ action: SliderAction) -> SafeNest {
  let path = SliderAction.actionPath

  switch action {
  case .input(let value):
    return try! state.updating(at: path, value: value)
  }
}

public final class ViewController: UIViewController {
  @IBOutlet fileprivate weak var counterTF: UITextField!
  @IBOutlet fileprivate weak var addBT: UIButton!
  @IBOutlet fileprivate weak var minusBT: UIButton!

  @IBOutlet fileprivate weak var stringTF1: UITextField!
  @IBOutlet fileprivate weak var stringTF2: UITextField!

  @IBOutlet fileprivate weak var slideTF: UITextField!
  @IBOutlet fileprivate weak var valueSL: UISlider!

  fileprivate let disposeBag = DisposeBag()

  fileprivate var dispatchStore: ConcurrentGenericDispatchStore<SafeNest>!
  fileprivate var rxStore: RxReduxStore<SafeNest>!

  deinit {
    let id = String(describing: ViewController.self)
    _ = dispatchStore?.unregister(id)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    counterTF.isEnabled = false
    stringTF1.isEnabled = false
    slideTF.isEnabled = false

    let deleteBtn = UIBarButtonItem(title: "Clear state",
                                    style: .plain,
                                    target: self,
                                    action: #selector(self.deleteButtonTapped))

    navigationItem.rightBarButtonItem = deleteBtn
    setupRxStore()
  }

  @objc func addButtonTapped() {
    DispatchQueue.global(qos: .background).async {
      let actionCount = Int.random(0, 100)
      let actions = (0..<actionCount).map({_ in NumberAction.add})
      self.dispatchStore!.dispatch(actions)
    }
  }

  @objc func minusButtonTapped() {
    let actionCount = Int.random(0, 100)
    let actions = (0..<actionCount).map({_ in NumberAction.minus})
    dispatchStore!.dispatch(actions)
  }

  @objc func string2Changed() {
    dispatchStore!.dispatch(StringAction.input(stringTF2!.text!))
  }

  @objc func sliderChanged() {
    let value = Double(valueSL!.value).rounded(.toNearestOrAwayFromZero)
    dispatchStore!.dispatch(SliderAction.input(value))
  }

  @objc func deleteButtonTapped() {
    dispatchStore?.dispatch([ClearAction.triggerClear, ClearAction.resetClear])
  }

  fileprivate func setupRxStore() {
    let disposeBag = self.disposeBag
    let initial = SafeNest()
    rxStore = RxReduxStore.createInstance(initial, mainReducer)

    /// Listen to global state.
    rxStore.stateStream()
      .map({$0.value(at: NumberAction.actionPath).cast(Int.self)})
      .mapNonNilOrElse({$0.asOptional()}, 0)
      .map({String(describing: $0)})
      .distinctUntilChanged()
      .bind(to: counterTF.rx.text)
      .disposed(by: disposeBag)

    let stringStream = rxStore.stateStream()
      .map({$0.value(at: StringAction.actionPath).cast(String.self)})
      .mapNonNilOrElse({$0.asOptional()}, "Input on the right")
      .map({String(describing: $0)})
      .distinctUntilChanged()
      .logNext()
      .share(replay: 1)

    stringStream.bind(to: stringTF1.rx.text).disposed(by: disposeBag)
    stringStream.bind(to: stringTF2.rx.text).disposed(by: disposeBag)

    let sliderStream = rxStore.stateStream()
      .map({$0.value(at: SliderAction.actionPath).cast(Double.self)})
      .mapNonNilOrElse({$0.asOptional()}, 0)
      .distinctUntilChanged()
      .share(replay: 1)

    sliderStream
      .map({String(describing: $0)})
      .bind(to: slideTF.rx.text)
      .disposed(by: disposeBag)

    sliderStream
      .map({Float($0)})
      .bind(to: valueSL.rx.value)
      .disposed(by: disposeBag)

    /// Dispatch to global state.
    navigationItem.rightBarButtonItem!.rx.tap.asObservable()
      .map({_ in ClearAction.triggerClear})
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    addBT.rx.tap.asObservable()
      .map({_ in NumberAction.add})
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    minusBT.rx.tap.asObservable()
      .map({_ in NumberAction.minus})
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    stringTF2.rx.text.asObservable()
      .mapNonNilOrEmpty()
      .map(StringAction.input)
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    valueSL.rx.value.asObservable()
      .map({Int($0)})
      .map({Double($0).rounded(.toNearestOrAwayFromZero)})
      .map(SliderAction.input)
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)
  }
}
