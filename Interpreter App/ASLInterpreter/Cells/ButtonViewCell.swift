//
//  ButtonViewCell.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 2/4/21.
//

import UIKit

class ButtonViewCell: UITableViewCell, BaseConfigurationCell {
    
    let button: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.tintColor = .white
        view.backgroundColor = .systemBlue
        view.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        return view
    }()
    
    var onDone: (() -> Void)?
    
    var item: ConfigurationItem? {
        didSet {
            guard let item = item else {
                return
            }
            
            button.setTitle(item.title, for: .normal)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(doAction(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate ( [
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 300),
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc func doAction(_ sender: UIButton) {
        onDone?()
    }
}
