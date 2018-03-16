//
//  HMStateStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 28/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

/// A Redux-compliant store that specifically handles HMState.
public typealias HMStateStore = HMReduxStore<HMState>

public extension HMReduxStore where State == HMState {
	
	/// Convenience method to create a store with an empty state.
	///
	/// - Parameter mainReducer: A HMReducer instance.
	/// - Returns: A HMReduxStore instance.
	public static func createInstance(
		_ mainReducer: @escaping HMReducer<State>) -> HMReduxStore<State>
	{
		return createInstance(.empty(), mainReducer)
	}
	
	/// Subscribe to this stream to receive notifications for a particular
	/// substate.
	///
	/// - Parameter identifier: A String value.
	/// - Returns: An Observable instance.
	public func substateStream(_ identifier: String) -> Observable<State?> {
		return stateStream().map({$0.substate(identifier)})
	}
	
	/// Subscribe to this stream to receive notifications for a particular
	/// state value.
	///
	/// - Parameter identifier: A String value.
	/// - Returns: An Observable instance.
	public func stateValueStream(_ identifier: String) -> Observable<Any?> {
		return stateStream().map({$0.stateValue(identifier)})
	}
	
	/// Subscribe to this stream to receive notifications for a state value of
	/// a specified type.
	///
	/// - Parameters:
	///   - cls: The T class type.
	///   - identifier: A String value.
	/// - Returns: An Observable instance.
	public func stateValueStream<T>(_ cls: T.Type, _ identifier: String) -> Observable<T?> {
		return stateValueStream(identifier).map({$0 as? T})
	}
}
