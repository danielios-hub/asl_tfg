//
//  BaseConfigurationCell.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit

protocol BaseConfigurationCell: UITableViewCell {
    var item: ConfigurationItem? { get set}
    var onDone: (() -> Void)? { get set }
}


