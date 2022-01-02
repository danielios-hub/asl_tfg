//
//  SwitchViewCell.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit

class SwitchViewCell: UITableViewCell, BaseConfigurationCell {
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let switchClass: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setOn(true, animated: false)
        return view
    }()
    
    let horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    var item: ConfigurationItem? {
        didSet {
            guard let item = item else {
                return
            }
            labelTitle.text = item.title
            
            if let value = item.value as? Bool {
                switchClass.setOn(value, animated: false)
                switchClass.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
            }
        }
    }
    
    var onDone: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        horizontalStackView.fillLayout(inView: contentView, marginsLateral: 20)
        horizontalStackView.addArrangedSubview(labelTitle)
        horizontalStackView.addArrangedSubview(switchClass)
    }
    
    @objc func switchDidChange(_ sender: UISwitch) {
        item?.value = sender.isOn
    }
}
