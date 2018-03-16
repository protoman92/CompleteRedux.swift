//
//  GeneralRedux+Global.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension GeneralReduxAction {
	public enum Global: ReduxActionType {
		case clearAll
	}
}

public extension GeneralReduxReducer {
	
	/// Global reducer.
	public final class Global {
		public typealias Action = GeneralReduxAction.Global
		
		public static func globalReducer(_ state: TreeState<Any>, _ action: Action) -> TreeState<Any> {
			switch action {
			case .clearAll: return state.clear()
			}
		}
	}
}
