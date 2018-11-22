//
//  ViewController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import RxCocoa
import RxSwift
import SafeNest

public final class ViewController: UIViewController {
  @IBOutlet fileprivate weak var counterTF: UITextField!
  @IBOutlet fileprivate weak var addBT: UIButton!
  @IBOutlet fileprivate weak var minusBT: UIButton!

  @IBOutlet fileprivate weak var stringTF1: UITextField!
  @IBOutlet fileprivate weak var stringTF2: UITextField!

  @IBOutlet fileprivate weak var slideTF: UITextField!
  @IBOutlet fileprivate weak var valueSL: UISlider!

  fileprivate let disposeBag = DisposeBag()
  fileprivate var rxStore: RxReduxStore<SafeNest>!

  override public func viewDidLoad() {
    super.viewDidLoad()
    counterTF.isEnabled = false
    stringTF1.isEnabled = false
    slideTF.isEnabled = false

    let deleteBtn = UIBarButtonItem(title: "Clear state",
                                    style: .plain,
                                    target: self,
                                    action: nil)

    navigationItem.rightBarButtonItem = deleteBtn
    setupRxStore()
  }

  fileprivate func setupRxStore() {
    let disposeBag = self.disposeBag
    let initial = SafeNest()
    rxStore = RxReduxStore.createInstance(initial, DataObjectRedux.reduceMain)

    /// Listen to global state.
    rxStore.stateStream()
      .map({$0
        .value(at: DataObjectRedux.Path.numberPath)
        .cast(Int.self)
        .getOrElse(0)})
      .map({String(describing: $0)})
      .distinctUntilChanged()
      .bind(to: counterTF.rx.text)
      .disposed(by: disposeBag)

    let stringStream = rxStore.stateStream()
      .map({$0
        .value(at: DataObjectRedux.Path.stringPath)
        .cast(String.self)
        .getOrElse("Input on the right")})
      .map({String(describing: $0)})
      .distinctUntilChanged()
      .share(replay: 1)

    stringStream.bind(to: stringTF1.rx.text).disposed(by: disposeBag)
    stringStream.bind(to: stringTF2.rx.text).disposed(by: disposeBag)

    let sliderStream = rxStore.stateStream()
      .map({$0
        .value(at: DataObjectRedux.Path.sliderPath)
        .cast(Double.self)
        .getOrElse(0)})
      .distinctUntilChanged()
      .share(replay: 1)

    sliderStream
      .map({String(describing: $0)})
      .bind(to: slideTF.rx.text)
      .disposed(by: disposeBag)

    sliderStream
      .map({Float($0)})
      .bind(to: valueSL.rx.value)
      .disposed(by: disposeBag)

    /// Dispatch to global state.
    navigationItem.rightBarButtonItem!.rx.tap.asObservable()
      .map({_ in DataObjectRedux.ClearAction.triggerClear})
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    addBT.rx.tap.asObservable()
      .map({_ in DataObjectRedux.NumberAction.add})
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    minusBT.rx.tap.asObservable()
      .map({_ in DataObjectRedux.NumberAction.minus})
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    stringTF2.rx.text.asObservable()
      .map({$0.getOrElse("")})
      .map(DataObjectRedux.StringAction.input)
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)

    valueSL.rx.value.asObservable()
      .map({Int($0)})
      .map({Double($0).rounded(.toNearestOrAwayFromZero)})
      .map(DataObjectRedux.SliderAction.input)
      .bind(to: rxStore.actionTrigger())
      .disposed(by: disposeBag)
  }
}
