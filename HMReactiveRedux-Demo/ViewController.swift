//
//  ViewController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import RxSwift
import SwiftFP
import UIKit

public enum ClearAction: ReduxActionType {
	case clearState
}

public enum NumberAction: ReduxActionType {
	case add
	case minus
	
	public static var path: String {
		return "main.number"
	}
	
	public static var actionPath: String {
		return "\(path).action"
	}
	
	public static var action2Path: String {
		return "\(path).action2"
	}
}

public enum StringAction: ReduxActionType {
	case input(String)
	
	public static var path: String {
		return "main.string"
	}
	
	public static var actionPath: String {
		return "\(path).action"
	}
}

public enum SliderAction: ReduxActionType {
	case input(Double)
	
	public static var path: String {
		return "main.slider"
	}
	
	public static var actionPath: String {
		return "\(path).action"
	}
}

public func mainReducer(_ state: TreeState<Any>, _ action: ReduxActionType) -> TreeState<Any> {
	switch action {
	case let action as ClearAction: return clearReducer(state, action)
	case let action as NumberAction: return numberReducer(state, action)
	case let action as StringAction: return stringReducer(state, action)
	case let action as SliderAction: return sliderReducer(state, action)
	default: return state
	}
}

public func clearReducer(_ state: TreeState<Any>, _ action: ClearAction) -> TreeState<Any> {
	switch action {
	case .clearState:
		return state
			.removeSubstate(NumberAction.path)
			.removeSubstate(StringAction.path)
			.removeSubstate(SliderAction.path)
	}
}

public func numberReducer(_ state: TreeState<Any>, _ action: NumberAction) -> TreeState<Any> {
	let path = NumberAction.actionPath
	
	switch action {
	case .add:
		return state.map(path, {
			return $0.flatMap({$0 as? Int})
				.successOrElse(Try.success(0))
				.map({$0 + 1})
				.map({$0 as Any})
		})
		
	case .minus:
		return state.map(path, {
			return $0.flatMap({$0 as? Int})
				.successOrElse(Try.success(0))
				.map({$0 - 1})
				.map({$0 as Any})
		})
	}
}

public func stringReducer(_ state: TreeState<Any>, _ action: StringAction) -> TreeState<Any> {
	let path = StringAction.actionPath
	
	switch action {
	case .input(let string):
		return state.updateValue(path, string)
	}
}

public func sliderReducer(_ state: TreeState<Any>, _ action: SliderAction) -> TreeState<Any> {
	let path = SliderAction.actionPath
	
	switch action {
	case .input(let value):
		return state.updateValue(path, value)
	}
}

public final class ViewController: UIViewController {
	@IBOutlet fileprivate weak var counterTF: UITextField!
	@IBOutlet fileprivate weak var addBT: UIButton!
	@IBOutlet fileprivate weak var minusBT: UIButton!
	
	@IBOutlet fileprivate weak var stringTF1: UITextField!
	@IBOutlet fileprivate weak var stringTF2: UITextField!
	
	@IBOutlet fileprivate weak var slideTF: UITextField!
	@IBOutlet fileprivate weak var valueSL: UISlider!
	
	fileprivate let disposeBag = DisposeBag()
	
	fileprivate var store: RxReduxStore<Any>!
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		counterTF.isEnabled = false
		stringTF1.isEnabled = false
		slideTF.isEnabled = false
		
		let deleteBtn = UIBarButtonItem(title: "Clear state",
																		style: .plain,
																		target: nil,
																		action: nil)
		
		navigationItem.rightBarButtonItem = deleteBtn
		
		let initial = TreeState<Any>.empty()
		
		store = RxReduxStore.createInstance(initial, mainReducer)
		
		store.stateValueStream(NumberAction.actionPath)
			.map({$0.flatMap({$0 as? Int})})
			.mapNonNilOrElse(0)
			.map({String(describing: $0)})
			.distinctUntilChanged()
			.bind(to: counterTF.rx.text)
			.disposed(by: disposeBag)
		
		store.stateValueStream(StringAction.actionPath)
			.map({$0.flatMap({$0 as? String})})
			.mapNonNilOrElse("Input on the right")
			.map({String(describing: $0)})
			.distinctUntilChanged()
			.bind(to: stringTF1.rx.text)
			.disposed(by: disposeBag)
		
		store.stateValueStream(SliderAction.actionPath)
			.map({$0.flatMap({$0 as? Double})})
			.mapNonNilOrElse(0)
			.map({String(describing: $0)})
			.distinctUntilChanged()
			.bind(to: slideTF.rx.text)
			.disposed(by: disposeBag)
		
		deleteBtn.rx.tap.asObservable()
			.map({_ in ClearAction.clearState})
			.bind(to: store.actionTrigger())
			.disposed(by: disposeBag)
		
		addBT.rx.tap.asObservable()
			.map({_ in NumberAction.add})
			.bind(to: store.actionTrigger())
			.disposed(by: disposeBag)
		
		minusBT.rx.tap.asObservable()
			.map({_ in NumberAction.minus})
			.bind(to: store.actionTrigger())
			.disposed(by: disposeBag)
		
		stringTF2.rx.text.asObservable()
			.mapNonNilOrEmpty()
			.map(StringAction.input)
			.bind(to: store.actionTrigger())
			.disposed(by: disposeBag)
		
		valueSL.rx.value.asObservable()
			.map({Int($0)})
			.map({Double($0).rounded(.toNearestOrAwayFromZero)})
			.map(SliderAction.input)
			.bind(to: store.actionTrigger())
			.disposed(by: disposeBag)
	}
}
