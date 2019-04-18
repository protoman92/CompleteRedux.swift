//
//  iTunesController.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux
import UIKit

public final class ViewController1: UIViewController {
  @IBOutlet private weak var counterLabel: UILabel!
  @IBOutlet private weak var tableView: UITableView!
  
  public let uniqueID = DefaultUniqueIDProvider.next()
  
  public var staticProps: StaticProps!
  
  public var reduxProps: ReduxProps? {
    didSet { self.reduxProps.map(self.didSetProps) }
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.counterLabel.layer.cornerRadius = 4
    self.counterLabel.layer.borderWidth = 1
    self.counterLabel.layer.borderColor = UIColor.gray.cgColor
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "iTunes search",
      style: .plain,
      target: self,
      action: #selector(self.goToITunesSearch))
  }
  
  func didSetProps(_ props: ReduxProps) {
    self.counterLabel.text = String(describing: props.state.counter)
    self.tableView.reloadData()
  }
  
  @IBAction func incrementCounter(_ sender: UIButton) {
    self.reduxProps?.action.incrementCounter()
  }
  
  @objc func goToITunesSearch(_ sender: UIBarButtonItem) {
    self.reduxProps?.action.goToITunesSearch()
  }
}

// MARK: - UITableViewDataSource
extension ViewController1: UITableViewDataSource {
  public func tableView(_ tableView: UITableView,
                        numberOfRowsInSection section: Int) -> Int {
    return self.reduxProps?.state.valueCount ?? 0
  }
  
  public func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView
      .dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
      as! TableCell
    
    self.staticProps?.injector.injectProps(view: cell, outProps: indexPath.row)
    return cell
  }
}

// MARK: - UITableViewDelegate
extension ViewController1: UITableViewDelegate {
  public func tableView(_ tableView: UITableView,
                        heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
}

// MARK: - PropContainerType
extension ViewController1: PropContainerType {
  public typealias GlobalState = AppState
  public typealias OutProps = ()
  
  public struct StateProps: Equatable {
    let counter: Int
    let valueCount: Int
  }
  
  public struct ActionProps {
    let incrementCounter: () -> Void
    let goToITunesSearch: () -> Void
  }
}

// MARK: - PropMapperType
extension ViewController1: PropMapperType {
  public static func mapState(state: AppState, outProps: OutProps) -> StateProps {
    return StateProps(counter: state.counter,
                      valueCount: state.textValueList.count)
  }
  
  public static func mapAction(dispatch: @escaping ReduxDispatcher,
                               state: GlobalState,
                               outProps: OutProps) -> ActionProps {
    return ActionProps(
      incrementCounter: {dispatch(AppAction.incrementCounter)},
      goToITunesSearch: {dispatch(AppScreen.iTunesSearch)}
    )
  }
}
