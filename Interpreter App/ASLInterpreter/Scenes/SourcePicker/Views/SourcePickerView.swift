//
//  SourcePickerView.swift
//  ASLInterpreter
//
//  Created by Daniel Gallego Peralta on 27/3/21.
//

import UIKit

class SourcePickerView: UIView {
    
    public weak var delegate: SourcePickerDelegate?
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        return stackView
    }()
    
    private struct ViewTraits {
        static let imageSize: CGFloat = 100
        static let stackHeight: CGFloat = 160
        static let paddingStack: CGFloat = 50
        static let cornerRadius: CGFloat = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(stackView)
        self.backgroundColor = .systemGray6
        setupConstraints()
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate ( [
            stackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: ViewTraits.paddingStack),
            stackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -ViewTraits.paddingStack),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: ViewTraits.stackHeight)
            
       ])
    }
    
    public func addSources(sources: [Source]) {
        
        sources.forEach { source in
            let verticalStack = createStackViewSource()
           
            let label = createLabelOption(with: source.title)
            let imageView = createImageView(with: source.image)
            
            verticalStack.addArrangedSubview(imageView)
            verticalStack.addArrangedSubview(label)
            
            NSLayoutConstraint.activate ( [
                imageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageSize),
                imageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageSize),
            ])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(doAction(sender:)))
            verticalStack.addGestureRecognizer(tap)
            verticalStack.tag = source.type.rawValue
            verticalStack.isUserInteractionEnabled = true
            
            stackView.addArrangedSubview(verticalStack)
           
        }
    }
    
    private func createStackViewSource() -> UIStackView {
        let verticalStack = UIStackView()
        verticalStack.backgroundColor = .white
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillProportionally
        verticalStack.alignment = .center
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStack.layer.cornerRadius = ViewTraits.cornerRadius
        
        verticalStack.isLayoutMarginsRelativeArrangement = true
        verticalStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        return verticalStack
    }
    
    private func createLabelOption(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = text
        label.textAlignment = .center
        return label
    }
    
    private func createImageView(with image: UIImage?) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    @objc func doAction(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else {
            return
        }
        
        switch tag {
        case SourceType.realTime.rawValue:
            self.delegate?.didSelectLiveCamera()
        case SourceType.library.rawValue:
            self.delegate?.didSelectLibrary()
        case SourceType.iCloud.rawValue:
            self.delegate?.didSelectiCloud()
        default: break
        }
    }
}
