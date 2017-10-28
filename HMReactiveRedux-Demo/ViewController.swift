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

public enum ClearAction: HMActionType {
    case clearState
}

public enum NumberAction: HMActionType {
    case add
    case minus
    
    public static var path: String {
        return "main.number"
    }
    
    public static var actionPath: String {
        return "\(path).action"
    }
}

public enum StringAction: HMActionType {
    case input(String)
    
    public static var path: String {
        return "main.string"
    }
    
    public static var actionPath: String {
        return "\(path).action"
    }
}

public enum SliderAction: HMActionType {
    case input(Double)
    
    public static var path: String {
        return "main.slider"
    }
    
    public static var actionPath: String {
        return "\(path).action"
    }
}

public func mainReducer(_ state: HMState, _ action: HMActionType) -> HMState {
    switch action {
    case let action as ClearAction: return clearReducer(state, action)
    case let action as NumberAction: return numberReducer(state, action)
    case let action as StringAction: return stringReducer(state, action)
    case let action as SliderAction: return sliderReducer(state, action)
    default: return state
    }
}

public func clearReducer(_ state: HMState, _ action: ClearAction) -> HMState {
    switch action {
    case .clearState:
        return state
            .updateSubstate(NumberAction.path, nil)
            .updateSubstate(StringAction.path, nil)
            .updateSubstate(SliderAction.path, nil)
    }
}

public func numberReducer(_ state: HMState, _ action: NumberAction) -> HMState {
    let path = NumberAction.actionPath
    
    switch action {
    case .add:
        return state.mapValue(Int.self, path, {($0 ?? 0) + 1})
        
    case .minus:
        return state.mapValue(Int.self, path, {($0 ?? 0) - 1})
    }
}

public func stringReducer(_ state: HMState, _ action: StringAction) -> HMState {
    let path = StringAction.actionPath
    
    switch action {
    case .input(let string):
        return state.mapValue(String.self, path, {_ in string})
    }
}

public func sliderReducer(_ state: HMState, _ action: SliderAction) -> HMState {
    let path = SliderAction.actionPath
    
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
        
        let deleteBtn = UIBarButtonItem(title: "Clear state",
                                        style: .plain,
                                        target: nil,
                                        action: nil)
        
        navigationItem.rightBarButtonItem = deleteBtn
        
        let initial = HMState.empty()
        
        store = HMStateStore.mainThreadVariant(initial, mainReducer)
        
        store.stateValueStream(NumberAction.actionPath)
            .mapNonNilOrElse({$0 as? Int}, 0)
            .map({String(describing: $0)})
            .distinctUntilChanged()
            .bind(to: counterTF.rx.text)
            .disposed(by: disposeBag)
        
        store.stateValueStream(StringAction.actionPath)
            .mapNonNilOrElse({$0 as? String}, "Input on the right")
            .distinctUntilChanged()
            .bind(to: stringTF1.rx.text)
            .disposed(by: disposeBag)
        
        store.stateValueStream(SliderAction.actionPath)
            .mapNonNilOrElse({$0 as? Double}, 0)
            .map({String(describing: $0)})
            .distinctUntilChanged()
            .bind(to: slideTF.rx.text)
            .disposed(by: disposeBag)
        
        deleteBtn.rx.tap.asObservable()
            .map({_ in ClearAction.clearState})
            .bind(to: store.actionTrigger())
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
