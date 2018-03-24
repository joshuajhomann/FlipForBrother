//
//  CGFloatExtension.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

extension CGFloat {
    func lerp(to: CGFloat, alpha: CGFloat) -> CGFloat {
        return (1 - alpha) * self + alpha * to
    }
}

