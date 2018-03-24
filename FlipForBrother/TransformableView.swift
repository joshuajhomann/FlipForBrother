//
//  TransformableView.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

class TransformableView: UIImageView {
    var transformableImage: TransformableImage {
        didSet {
            calculateTransform()
        }
    }
    var isSelected: Bool = false {
        didSet {
            layer.shadowRadius = isSelected ? 3 : 0
        }
    }
    init(transformableImage: TransformableImage) {
        self.transformableImage = transformableImage
        super.init(frame: CGRect(x: 0, y: 0, width: transformableImage.image?.size.width ?? 0, height: transformableImage.image?.size.height ?? 0))
        layer.borderColor = UIColor.black.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        layer.shadowColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
        calculateTransform()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func updateImage() {
        image = transformableImage.image
    }

    func calculateTransform() {
        transform = transformableImage.transform
    }
    
}
