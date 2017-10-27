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

public func mainReducer(_ state: HMState, _ action: HMActionType) -> HMState {
    switch action {
    case let action as NumberAction: return numberReducer(state, action)
    default: return state
    }
}

public func numberReducer(_ state: HMState, _ action: NumberAction) -> HMState {
    let path = NumberAction.path
    
    switch action {
    case .add:
        return state.updateValueFn(Int.self, path, {($0 ?? 0) + 1})
        
    case .minus:
        return state.updateValueFn(Int.self, path, {($0 ?? 0) - 1})
    }
}

public final class ViewController: UIViewController {
    @IBOutlet fileprivate weak var counterTF: UITextField!
    @IBOutlet fileprivate weak var addBT: UIButton!
    @IBOutlet fileprivate weak var minusBT: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var store: HMReduxStore<HMState>!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let initial = HMState.empty()
        
        store = HMReduxStore<HMState>.mainThreadVariant(initial, mainReducer)
        
        let stateStream = store.stateStream().shareReplay(1)
        
        stateStream
            .map({$0.stateValue(NumberAction.path)})
            .mapNonNilOrEmpty()
            .map({String(describing: $0)})
            .bind(to: counterTF.rx.text)
            .disposed(by: disposeBag)
        
        addBT.rx.tap.asObservable()
            .map({_ in NumberAction.add})
            .bind(to: store.actionTrigger())
            .disposed(by: disposeBag)
        
        minusBT.rx.tap.asObservable()
            .map({_ in NumberAction.minus})
            .bind(to: store.actionTrigger())
            .disposed(by: disposeBag)
    }
}
