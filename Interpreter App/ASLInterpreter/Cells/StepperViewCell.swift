//
//  StepperViewCell.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit

class StepperViewCell: UITableViewCell, BaseConfigurationCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.isContinuous = false
        stepper.minimumValue = 1
        stepper.maximumValue = 6
        return stepper
    }()
    
    var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    var item: ConfigurationItem? {
        didSet {
            guard let item = item else {
                return
            }
            titleLabel.text = item.title
            
            if let value = item.value as? Int {
                stepper.value = Double(value)
                valueLabel.text = String(value)
                stepper.addTarget(self, action: #selector(stepperDidChange), for: .valueChanged)
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
        horizontalStackView.addArrangedSubview(titleLabel)
        horizontalStackView.addArrangedSubview(stepper)
        horizontalStackView.addArrangedSubview(valueLabel)
    }
    
    @objc func stepperDidChange(_ sender: UIStepper) {
        let value = Int(sender.value)
        item?.value = value
        valueLabel.text = String(value)
    }
}
