//
//  HMReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftUtilities

/// A Redux-compliant store.
public struct HMReduxStore<S: HMStateType> {
    
    /// Create a redux store that only receives and delivers events on the main
    /// thread.
    ///
    /// - Parameters:
    ///   - initialState: A State instance.
    ///   - mainReducer: A HMReducer instance.
    /// - Returns: A HMReduxStore instance.
    public static func createInstance(
        _ initialState: State,
        _ mainReducer: @escaping HMReducer<State>) -> HMReduxStore<State>
    {
        let store = HMReduxStore(initialState)
        store.setupStateBindings(mainReducer)
        return store
    }
    
    fileprivate let disposeBag: DisposeBag
    fileprivate var rdActionTrigger: PublishSubject<Action?>
    fileprivate var rdActionVariable: Variable<Action?>
    fileprivate var rdStateVariable: Variable<State>
    
    fileprivate init(_ initialState: State) {
        disposeBag = DisposeBag()
        rdActionVariable = Variable<Action?>(nil)
        rdActionTrigger = PublishSubject<Action?>()
        rdStateVariable = Variable(initialState)
    }
    
    fileprivate func setupStateBindings(_ reducer: @escaping HMReducer<State>) {
        let disposeBag = self.disposeBag
        let initialState = rdStateVariable.value
        let actionStream = rdActionVariable.asObservable().mapNonNilOrEmpty()
        
        rdActionTrigger
            .bind(to: rdActionVariable)
            .disposed(by: disposeBag)
        
        createState(actionStream, initialState, reducer)
            .bind(to: rdStateVariable)
            .disposed(by: disposeBag)
    }
}

extension HMReduxStore: HMReduxStoreType {
    public typealias State = S
    
    public func actionTrigger() -> AnyObserver<Action?> {
        return rdActionTrigger.asObserver()
    }
    
    public func stateStream() -> Observable<State> {
        return rdStateVariable.asDriver().asObservable()
    }
}
