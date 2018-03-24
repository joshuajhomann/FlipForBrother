//
//  AnimationViewController.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {

    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var canvasViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasViewHeightConstraint: NSLayoutConstraint!
    var keyFrames: [KeyFrame] = []
    var proposedSize: CGSize = .zero
    let animationTime: TimeInterval = 5
    var frame = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasViewWidthConstraint.constant = proposedSize.width
        canvasViewHeightConstraint.constant = proposedSize.height
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
        animate()
    }

    func animate() {
        guard (keyFrames.first?.transformableImages.count ?? 0) > 0 else {
            return
        }
        self.canvasView.subviews.flatMap{ $0 as? TransformableView}.enumerated().forEach {
                $0.element.isHidden = self.keyFrames[self.frame].transformableImages[$0.offset].isHidden
                $0.element.image = self.keyFrames[self.frame].transformableImages[$0.offset].image
                $0.element.transform = self.keyFrames[self.frame].transformableImages[$0.offset].transform
            }
        frame += 1
        frame %= keyFrames.count
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 / 12.0) {
            self.animate()
        }
    }

    func setup() {
        canvasView.subviews.forEach{$0.removeFromSuperview()}
        keyFrames.first?.transformableImages.map { TransformableView(transformableImage: $0) }
            .forEach {self.canvasView.addSubview($0)
                $0.center = self.canvasView.center
                $0.center.x -= self.canvasView.frame.origin.x
                $0.center.y -= self.canvasView.frame.origin.y
                $0.updateImage()
        }
        canvasView.setNeedsDisplay()
    }

    @IBAction func tapOutsise(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
