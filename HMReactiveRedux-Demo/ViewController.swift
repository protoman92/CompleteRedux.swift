//
//  ViewController.swift
//  HMReactiveRedux-Demo
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import HMReactiveRedux
import SafeNest

final class ViewController: UIViewController {
  @IBOutlet private weak var counterTF: UITextField!
  @IBOutlet private weak var addBT: UIButton!
  @IBOutlet private weak var minusBT: UIButton!
  @IBOutlet private weak var stringTF1: UITextField!
  @IBOutlet private weak var stringTF2: UITextField!
  @IBOutlet private weak var slideTF: UITextField!
  @IBOutlet private weak var valueSL: UISlider!
  
  public var reduxProps: ReduxProps? {
    didSet {
      if let props = self.reduxProps {
        didSetReduxProps(props)
      }
    }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.counterTF.isEnabled = false
    self.stringTF1.isEnabled = false
    self.slideTF.isEnabled = false

    navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: "Clear state",
                      style: .plain,
                      target: self,
                      action: #selector(self.clearAll))
  }
  
  private func didSetReduxProps(_ props: ReduxProps) {
    let (stateProps, _) = props
    self.counterTF.text = stateProps.number.map(String.init)
    self.slideTF.text = stateProps.slider.map(String.init)
    self.stringTF1.text = stateProps.string
    self.stringTF2.text = stateProps.string
    self.valueSL.value = stateProps.slider ?? valueSL.value
  }
  
  @objc func clearAll(_ sender: UIBarButtonItem) {
    self.reduxProps?.dispatch.clearAll()
  }
  
  @IBAction func incrementNumber(_ sender: UIButton) {
    self.reduxProps?.dispatch.incrementNumber()
  }
  
  @IBAction func decrementNumber(_ sender: UIButton) {
    self.reduxProps?.dispatch.decrementNumber()
  }
  
  @IBAction func updateString(_ sender: UITextField) {
    self.reduxProps?.dispatch.updateString(sender.text)
  }
  
  @IBAction func updateSlider(_ sender: UISlider) {
    self.reduxProps?.dispatch.updateSlider(Double(sender.value))
  }
}

extension ViewController {
  struct StateProps {
    public let number: Int?
    public let slider: Float?
    public let string: String?
  }
  
  struct DispatchProps {
    let clearAll: () -> Void
    let incrementNumber: () -> Void
    let decrementNumber: () -> Void
    let updateSlider: (Double) -> Void
    let updateString: (String?) -> Void
  }
}

extension ViewController.StateProps: Equatable {}
extension ViewController.StateProps: Decodable {}

extension ViewController: ReduxConnectableView {
  static func mapStateToProps(state: SafeNest) -> StateProps {
    return state
      .decode(at: Redux.Path.rootPath, ofType: StateProps.self)
      .getOrElse(StateProps(number: nil, slider: nil, string: nil))
  }
  
  static func mapDispatchToProps(dispatch: @escaping ReduxDispatch) -> DispatchProps {
    return DispatchProps(
      clearAll: {dispatch(Redux.ClearAction.triggerClear)},
      incrementNumber: {dispatch(Redux.NumberAction.add)},
      decrementNumber: {dispatch(Redux.NumberAction.minus)},
      updateSlider: {dispatch(Redux.SliderAction.input($0))},
      updateString: {dispatch(Redux.StringAction.input($0))}
    )
  }
}
