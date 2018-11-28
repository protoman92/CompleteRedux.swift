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
  
  public var staticProps: StaticProps?
  
  public var variableProps: VariableProps? {
    didSet {
      if let props = self.variableProps {
        self.didSetReduxProps(props)
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
  
  private func didSetReduxProps(_ props: VariableProps) {
    self.counterTF.text = props.state?.number.map(String.init)
    self.slideTF.text = props.state?.slider.map(String.init)
    self.stringTF1.text = props.state?.string
    self.stringTF2.text = props.state?.string
    self.valueSL.value = props.state?.slider ?? valueSL.value
  }
  
  @objc func clearAll(_ sender: UIBarButtonItem) {
    self.staticProps?.dispatch?.clearAll()
  }
  
  @IBAction func incrementNumber(_ sender: UIButton) {
    self.staticProps?.dispatch?.incrementNumber()
  }
  
  @IBAction func decrementNumber(_ sender: UIButton) {
    self.staticProps?.dispatch?.decrementNumber()
  }
  
  @IBAction func updateString(_ sender: UITextField) {
    self.staticProps?.dispatch?.updateString(sender.text)
  }
  
  @IBAction func updateSlider(_ sender: UISlider) {
    self.staticProps?.dispatch?.updateSlider(Double(sender.value))
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
extension ViewController: ReduxCompatibleViewType {}
