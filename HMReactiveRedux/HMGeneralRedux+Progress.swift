//
//  HMGeneralRedux+Progress.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension HMGeneralReduxAction {
	
	/// Progress-related actions.
	public final class Progress {
		public enum Display: HMActionType {
			case updateShowProgress(Bool)
			
			public static var path: String {
				return "progress.display"
			}
			
			public static var progressPath: String {
				return "\(path).progress"
			}
		}
	}
}

public extension HMGeneralReduxReducer {
	
	/// Progress reducer.
	final class Progress {
		typealias Display = HMGeneralReduxAction.Progress.Display
		
		static func displayReducer(_ state: HMState, _ action: Display) -> HMState {
			switch action {
			case .updateShowProgress(let show):
				return state.updateValue(Display.progressPath, show)
			}
		}
	}
}
