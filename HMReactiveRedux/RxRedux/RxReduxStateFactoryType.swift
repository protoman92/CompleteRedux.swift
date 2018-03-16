//
//  RxReduxStateFactoryType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

/// Classes that implement this protocol should be able to produce state based
/// on reducers.
public protocol RxReduxStateFactoryType {
	associatedtype State: StateType
}

public extension RxReduxStateFactoryType {

	/// Create a state stream that builds up from an initial state.
	///
	/// - Parameters:
	///   - actionTrigger: The action trigger Observable.
	///   - initialState: The initial state.
	///   - mainReducer: A Reducer function.
	/// - Returns: An Observable instance.
	public func createState<O>(_ actionTrigger: O,
														 _ initialState: State,
														 _ mainReducer: @escaping ReduxReducer<State>)
		-> Observable<State> where
		O: ObservableConvertibleType, O.E == ReduxActionType
	{
		return actionTrigger.asObservable()
			.scan(initialState, accumulator: mainReducer)
	}
}