//
//  ASLInterpreterView.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 28/3/21.
//

import UIKit

class ASLInterpreterView: UIView {
    
    var labelResults: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .green
        label.textAlignment = .center
        return label
    }()
    
    var labelDetectedWord: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(labelResults)
        self.addSubview(labelDetectedWord)
        
        NSLayoutConstraint.activate( [
            labelResults.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            labelResults.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            labelResults.heightAnchor.constraint(equalToConstant: 60),
            labelResults.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            labelDetectedWord.leadingAnchor.constraint(greaterThanOrEqualTo: labelResults.trailingAnchor, constant: 10),
            labelDetectedWord.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            labelDetectedWord.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            labelDetectedWord.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        labelDetectedWord.textAlignment = .right
        labelDetectedWord.backgroundColor = .white
        labelDetectedWord.layer.cornerRadius = 8
        labelDetectedWord.clipsToBounds = true
        labelDetectedWord.textColor = .black
    }
}
