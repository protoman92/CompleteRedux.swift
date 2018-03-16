//
//  HMGeneralRedux.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 23/11/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import SwiftUtilities

/// General Redux actions that are not tied to any specific app/implementation.
/// We can use these generic actions as building blocks for app-specific redux
/// deployments.
public final class HMGeneralReduxAction {
	private init() {}
}

/// General Redux reducer that is not tied to a specifiec app/implementation.
public final class HMGeneralReduxReducer {
	public static func generalReducer(_ state: HMState, _ action: HMActionType) -> HMState {
		switch action {
		case let action as Global.Action:
			return Global.globalReducer(state, action)
			
		case let action as Error.Display:
			return Error.displayReducer(state, action)
			
		case let action as Progress.Display:
			return Progress.displayReducer(state, action)
			
		default:
			debugException("Unhandled action: \(action)")
			return state
		}
	}
	
	private init() {}
}
