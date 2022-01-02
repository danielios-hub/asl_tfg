//
//  ConfigurationPickerViewCell.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit

class ConfigurationPickerViewCell: UITableViewCell, BaseConfigurationCell {
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let valueTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return textField
    }()
    
    let horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    lazy var pickerToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton(_:)))
        let flexibleButton = UIBarButtonItem(systemItem: .flexibleSpace)
        toolbar.setItems([flexibleButton, doneButton], animated: false)
        return toolbar
    }()
    
    var item: ConfigurationItem? {
        didSet {
            guard let item = item else {
                return
            }
            labelTitle.text = item.title
            selectedOption = item.options.filter {
                switch item.value {
                case is ASLConfiguration.HandCase:
                    return (item.value as? ASLConfiguration.HandCase) == $0.value as? ASLConfiguration.HandCase
                case is ASLConfiguration.ASLModel:
                    return (item.value as? ASLConfiguration.ASLModel) == $0.value as? ASLConfiguration.ASLModel
                case is ASLConfiguration.WorkingMode:
                    return (item.value as? ASLConfiguration.WorkingMode) == $0.value as? ASLConfiguration.WorkingMode
                default:
                    return false
                }
                
            }.first
            
            pickerView.reloadAllComponents()
            
            if let row = selectedRow {
                pickerView.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
    
    var selectedOption: SelectBox? {
        didSet {
            valueTextField.text = selectedOption?.text
            item?.value = selectedOption?.value as Any
        }
    }
    
    var selectedRow: Int? {
        guard let selectedOption = selectedOption else {
            return nil
        }
        return item?.options.firstIndex(of: selectedOption)
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
        horizontalStackView.addArrangedSubview(valueTextField)
        setupPickerView()
    }
    
    private func setupPickerView() {
        valueTextField.inputView = pickerView
        valueTextField.inputAccessoryView = pickerToolBar
    }
    
    //MARK: - Actions
    
    @objc func doneButton(_ sender: UIBarButtonItem) {
        valueTextField.resignFirstResponder()
    }
    
}

//MARK: - UIPickerView DataSource

extension ConfigurationPickerViewCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return item?.options.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return item?.options[row].text ?? ""
    }
    
}

extension ConfigurationPickerViewCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = item?.options[row]
    }
}
