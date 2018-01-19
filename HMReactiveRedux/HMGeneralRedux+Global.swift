//
//  HMGeneralRedux+Global.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/1/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

public extension HMGeneralReduxAction {
    public enum Global: HMActionType {
        case clearAll
    }
}

extension HMGeneralReduxReducer {
    
    /// Global reducer.
    final class Global {
        typealias Action = HMGeneralReduxAction.Global
        
        static func globalReducer(_ state: HMState, _ action: Action) -> HMState {
            switch action {
            case .clearAll: return state.clearAllState()
            }
        }
    }
}
