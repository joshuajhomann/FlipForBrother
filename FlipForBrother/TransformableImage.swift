//
//  TransformableImage.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

struct TransformableImage: Codable {
    var imageName: String
    var image: UIImage? {
        return UIImage(named: imageName)
    }
    var transform: CGAffineTransform {
        return CGAffineTransform(translationX: translation.x, y: translation.y)
                .rotated(by: rotation)
                .scaledBy(x: scaleX, y: scaleY)
    }
    var scaleX: CGFloat
    var scaleY: CGFloat
    var rotation: CGFloat
    var translation: CGPoint
    var isHidden = false
    mutating func lerp(from: TransformableImage, to: TransformableImage, proportion: CGFloat) {
        scaleX = from.scaleX.lerp(to: to.scaleX, alpha: proportion)
        scaleY = from.scaleY.lerp(to: to.scaleY, alpha: proportion)
        rotation = from.rotation.lerp(to: to.rotation, alpha: proportion)
        translation.x = from.translation.x.lerp(to: to.translation.x, alpha: proportion)
        translation.y = from.translation.y.lerp(to: to.translation.y, alpha: proportion)
    }
}
