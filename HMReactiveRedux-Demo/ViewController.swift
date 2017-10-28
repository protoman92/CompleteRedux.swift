//
//  ViewController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import HMReactiveRedux
import RxSwift
import UIKit

public final class ActionType {
    public static let numberAction = "NUMBER_ACTION"
    
    private init() {}
}

public enum NumberAction: HMActionType {
    case add
    case minus
    
    public static var path: String {
        return "main.number.action"
    }
}

public enum StringAction: HMActionType {
    case input(String)
    
    public static var path: String {
        return "main.string.action"
    }
}

public enum SliderAction: HMActionType {
    case input(Double)
    
    public static var path: String {
        return "main.slider.action"
    }
}

public func mainReducer(_ state: HMState, _ action: HMActionType) -> HMState {
    switch action {
    case let action as NumberAction: return numberReducer(state, action)
    case let action as StringAction: return stringReducer(state, action)
    case let action as SliderAction: return sliderReducer(state, action)
    default: return state
    }
}

public func numberReducer(_ state: HMState, _ action: NumberAction) -> HMState {
    let path = NumberAction.path
    
    switch action {
    case .add:
        return state.mapValue(Int.self, path, {($0 ?? 0) + 1})
        
    case .minus:
        return state.mapValue(Int.self, path, {($0 ?? 0) - 1})
    }
}

public func stringReducer(_ state: HMState, _ action: StringAction) -> HMState {
    let path = StringAction.path
    
    switch action {
    case .input(let string):
        return state.mapValue(String.self, path, {_ in string})
    }
}

public func sliderReducer(_ state: HMState, _ action: SliderAction) -> HMState {
    let path = SliderAction.path
    
    switch action {
    case .input(let value):
        return state.mapValue(Double.self, path, {_ in value})
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
    
    fileprivate var store: HMStateStore!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        counterTF.isEnabled = false
        stringTF1.isEnabled = false
        slideTF.isEnabled = false
        
        let initial = HMState.empty()
        
        store = HMStateStore.mainThreadVariant(initial, mainReducer)
        
        store.stateValueStream(Int.self, NumberAction.path)
            .map({String(describing: $0)})
            .distinctUntilChanged()
            .bind(to: counterTF.rx.text)
            .disposed(by: disposeBag)
        
        store.stateValueStream(String.self, StringAction.path)
            .distinctUntilChanged()
            .bind(to: stringTF1.rx.text)
            .disposed(by: disposeBag)
        
        store.stateValueStream(Double.self, SliderAction.path)
            .map({String(describing: $0)})
            .distinctUntilChanged()
            .bind(to: slideTF.rx.text)
            .disposed(by: disposeBag)
        
        addBT.rx.tap.asObservable()
            .map({_ in NumberAction.add})
            .bind(to: store.actionTrigger())
            .disposed(by: disposeBag)
        
        minusBT.rx.tap.asObservable()
            .map({_ in NumberAction.minus})
            .bind(to: store.actionTrigger())
            .disposed(by: disposeBag)
        
        stringTF2.rx.text.asObservable()
            .mapNonNilOrEmpty()
            .map(StringAction.input)
            .bind(to: store.actionTrigger())
            .disposed(by: disposeBag)
        
        valueSL.rx.value.asObservable()
            .map({Int($0)})
            .map({Double($0).rounded(.toNearestOrAwayFromZero)})
            .map(SliderAction.input)
            .bind(to: store.actionTrigger())
            .disposed(by: disposeBag)
    }
}
