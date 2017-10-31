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

/// A Redux-compliant store. Since this store is used for UI-related work, it
/// should operation on the main thread.
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
    fileprivate var rdActionVariable: Variable<Action?>
    fileprivate var rdStateVariable: Variable<State>
    
    fileprivate init(_ initialState: State) {
        disposeBag = DisposeBag()
        rdActionVariable = Variable<Action?>(nil)
        rdStateVariable = Variable(initialState)
    }
    
    fileprivate func setupStateBindings(_ reducer: @escaping HMReducer<State>) {
        let disposeBag = self.disposeBag
        let initialState = rdStateVariable.value
        let actionStream = rdActionVariable.asObservable().mapNonNilOrEmpty()
        
        createState(actionStream, initialState, reducer)
            .bind(to: rdStateVariable)
            .disposed(by: disposeBag)
    }
}

extension HMReduxStore: HMReduxStoreType {
    public typealias State = S
    
    public func actionTrigger() -> AnyObserver<Action?> {
        return rdActionVariable.asObserver()
    }
    
    public func stateStream() -> Observable<State> {
        return rdStateVariable.asDriver().asObservable()
    }
}

extension Variable: ObserverType {
    public typealias E = Element
    
    public func on(_ event: Event<Element>) {
        Preconditions.checkRunningOnMainThread(event)
        
        switch event {
        case .next(let event):
            self.value = event
            
        case .error(let error):
            debugPrint("Error \(error) received - ignoring.")
            
        case .completed:
            debugPrint("Completed signal received - ignoring.")
        }
    }
}
