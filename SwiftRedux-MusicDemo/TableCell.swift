//
//  TableCell.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/7/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux
import UIKit

public final class TableCell: UITableViewCell {
  @IBOutlet private weak var textField: UITextField!
  
  public let uniqueID = DefaultUniqueIDProvider.next()
  
  public var staticProps: StaticProps!

  public var reduxProps: ReduxProps? {
    didSet { self.reduxProps.map(self.didSetProps) }
  }
  
  func didSetProps(_ props: ReduxProps) {    
    self.textField.text = props.state.textValue
  }
  
  @IBAction func updateTextValue(_ sender: UITextField) {
    self.reduxProps?.action.updateTextValue(sender.text)
  }
}

// MARK: - PropContainerType
extension TableCell: PropContainerType {
  public typealias GlobalState = AppState
  public typealias OutProps = Int
  
  public struct StateProps: Equatable {
    let textValue: String?
  }
  
  public struct ActionProps {
    let updateTextValue: (String?) -> Void
  }
}

// MARK: - PropMapperType
extension TableCell: PropMapperType {
  public static func mapState(state: GlobalState, outProps: OutProps) -> StateProps {
    return StateProps(textValue: state.textValueList[outProps])
  }
  
  public static func mapAction(dispatch: @escaping ReduxDispatcher,
                               state: GlobalState,
                               outProps: OutProps) -> TableCell.ActionProps {
    return ActionProps(
      updateTextValue: {dispatch(AppAction.updateTextValue(outProps, $0))})
  }
}
