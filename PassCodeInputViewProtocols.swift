//
//  PassCodeInputViewProtocols.swift
//  QRDynamic
//
//  Created by Ольга on 14/08/2019.
//  Copyright © 2019 VTB. All rights reserved.
//

import UIKit

protocol PassCodeInputViewItemType: UIView {
    var label: UILabel! { get set }
    var line: UIImageView! { get set }
    var point: UIImageView! { get set }
    
    var value: Int? { get }
    var isEmpty: Bool { get }
    
    func set(value: Int)
    func clear()
    
    func define()
    func fill()
    func empty()
    func error()
}

protocol PassCodeInputViewDataSource: class {
    func numberOfElements() -> Int
}

protocol PassCodeInputViewDelegate: class {
    func heightForItem(at index: Int) -> CGFloat
    func passCodeViewIsOverDigits(_ result: String)
}
