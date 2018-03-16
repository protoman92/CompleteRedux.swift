//
//  GeneralRedux+Progress.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension GeneralReduxAction {
	
	/// Progress-related actions.
	public final class Progress {
		public enum Display: ReduxActionType {
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

public extension GeneralReduxReducer {
	
	/// Progress reducer.
	public final class Progress {
		public typealias Display = GeneralReduxAction.Progress.Display
		
		public static func displayReducer(_ state: TreeState<Any>, _ action: Display) -> TreeState<Any> {
			switch action {
			case .updateShowProgress(let show):
				return state.updateValue(Display.progressPath, show)
			}
		}
	}
}
