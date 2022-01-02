//
//  ConfigurationSliderViewCell.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit

class ConfigurationSliderViewCell: UITableViewCell, BaseConfigurationCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return slider
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
            
            if let value = item.value as? Float {
                slider.setValue(value, animated: false)
                valueLabel.text = String(format: "%.2f", value)
                slider.addTarget(self, action: #selector(valueSliderChange(_:)), for: .valueChanged)
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
        horizontalStackView.addArrangedSubview(slider)
        horizontalStackView.addArrangedSubview(valueLabel)
    }
    
    @objc func valueSliderChange(_ sender: UISlider) {
        let floatValue = sender.value.round(to: 2)
        item?.value = floatValue 
        valueLabel.text = String(format: "%.2f", floatValue)
    }
}
