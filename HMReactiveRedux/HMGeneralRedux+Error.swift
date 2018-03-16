//
//  HMGeneralRedux+Error.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension HMGeneralReduxAction {
	
	/// Error-related actions.
	public final class Error {
		public enum Display: HMActionType {
			case updateShowError(Swift.Error?)
			
			public static var path: String {
				return "error.display"
			}
			
			public static var errorPath: String {
				return "\(path).error"
			}
		}
	}
}

extension HMGeneralReduxReducer {
	
	/// Error reducer.
	final class Error {
		typealias Display = HMGeneralReduxAction.Error.Display
		
		static func displayReducer(_ state: HMState, _ action: Display) -> HMState {
			switch action {
			case .updateShowError(let error):
				return state.updateValue(Display.errorPath, error)
			}
		}
	}
}
