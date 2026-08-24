//
//  GradientView.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit

class GradientView: UIView {

    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }

    convenience init(topColor: UIColor, bottomColor: UIColor) {
        self.init(frame: .zero)

        backgroundColor = .clear

        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)

        layer.colors = [topColor.cgColor, bottomColor.cgColor]
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

}
