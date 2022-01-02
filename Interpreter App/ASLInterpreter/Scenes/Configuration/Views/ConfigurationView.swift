//
//  ConfigurationView.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit
import DGPExtensionCore

class ConfigurationView: UIView {
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(contentView)
        contentView.addSubview(tableView)
        
        setupConstraints()
        registerCells()
    }
    
    private func registerCells() {
        tableView.register(ConfigurationSliderViewCell.self, forCellReuseIdentifier: ConfigurationSliderViewCell.getIdentifier())
        tableView.register(ConfigurationPickerViewCell.self, forCellReuseIdentifier: ConfigurationPickerViewCell.getIdentifier())
        tableView.register(StepperViewCell.self, forCellReuseIdentifier: StepperViewCell.getIdentifier())
        tableView.register(SwitchViewCell.self, forCellReuseIdentifier: SwitchViewCell.getIdentifier())
        tableView.register(ButtonViewCell.self, forCellReuseIdentifier: ButtonViewCell.getIdentifier())
    }
    
    private func setupConstraints() {
        contentView.fillLayout(inView: self)
        contentView.backgroundColor = .systemGray6
        
        let maxWidth: CGFloat = 600
        NSLayoutConstraint.activate ( [
            tableView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            tableView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
