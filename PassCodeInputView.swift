//
//  PassCodeInputView.swift
//  QRDynamic
//
//  Created by Ольга on 12/08/2019.
//  Copyright © 2019 VTB. All rights reserved.
//

import UIKit

public enum PassCodeInputViewTypeView {
    case base
    case passsword
}

class PassCodeInputView<ItemView: PassCodeInputViewItemType>: UIView {
    
    // MARK: - Public
    public var notEmpty: Bool {
        return items?.first(where: {!$0.isEmpty}) != nil
    }
    
    private var isFull: Bool {
        return !(items?.first(where: {$0.isEmpty}) != nil)
    }
    
    // MARK: Private Properties
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        self.addSubviewThatsFit(stackView)
        return stackView
    }()
    
    private weak var dataSource: PassCodeInputViewDataSource?
    private weak var delegate: PassCodeInputViewDelegate?
    
    private var items: [PassCodeInputViewItemType]? {
        return stackView.arrangedSubviews as? [PassCodeInputViewItemType]
    }
    private var isHideDigits: Bool = false
    
    private var lastEmptyItem: PassCodeInputViewItemType? {
        return items?.first(where: {$0.isEmpty})
    }
    
    private var lastFillItem: PassCodeInputViewItemType? {
        return items?.last(where: {!$0.isEmpty})
    }
    
    private var result: String {
        return items?.map({ (item) -> String in
            if let value = item.value {
                return String(describing: value)
            }
            return ""
        }).joined() ?? ""
    }
    
    // MARK: Private methods
    private func createStackView(with count: Int?) {
        guard let count = count else {
            #if DEBUG
            print("PassCodeInputView: count items from dataSource is nil!")
            #endif
            return
        }
        
        for index in 0..<count {
            if let view = fromString(nameNib: ItemView.className) as? PassCodeInputViewItemType {
                stackView.addArrangedSubview(view)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalToConstant: delegate?.heightForItem(at: index) ?? .zero).isActive = true
            } else {
                #if DEBUG
                fatalError("PassCodeInputView: \(type(of: PassCodeInputViewItemType.self)) not conform to PassCodeInputViewItemType")
                #endif
            }
        }
    }
    
    private func updateView() {
        if (items?.filter({!$0.isEmpty}).isEmpty) ?? true {
            items?.forEach({$0.define()})
        } else {
            items?.filter({!$0.isEmpty}).forEach({$0.fill()})
            items?.filter({$0.isEmpty}).forEach({$0.empty()})
        }
    }
    
    private func updateDelegate() {
        if isFull {
            delegate?.passCodeViewIsOverDigits(result)
        }
    }
}

// MARK: - Public methods
extension PassCodeInputView {
    public func configure(dataSource: PassCodeInputViewDataSource, delegate: PassCodeInputViewDelegate) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.createStackView(with: self.dataSource?.numberOfElements())
        self.updateView()
    }
    
    public func write(digit: Int?) {
        guard let value = digit else {
            return
        }
        
        if !isFull {
            lastEmptyItem?.set(value: value)
            updateView()
            updateDelegate()
        }
    }
    
    public func writeBackspace() {
        lastFillItem?.clear()
        updateView()
        updateDelegate()
    }
    
    public func shake(isError: Bool = false) {
        if isError {
            items?.filter({!$0.isEmpty}).forEach({$0.error()})
        }
        
        let midX = stackView.center.x
        let midY = stackView.center.y
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.065
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: midX - 8, y: midY)
        animation.toValue = CGPoint(x: midX + 8, y: midY)
        stackView.layer.add(animation, forKey: "position")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.clear()
            self.updateView()
        }
        
    }
    
    public func clear() {
        items?.forEach({$0.clear()})
        updateView()
        updateDelegate()
    }
}

// MARK: - Internal methods
extension PassCodeInputView {
    internal func fromString<T: UIView>(nameNib: String) -> T? {
        return Bundle.main.loadNibNamed(String(describing: nameNib), owner: nil, options: nil)![0] as? T
    }
}
