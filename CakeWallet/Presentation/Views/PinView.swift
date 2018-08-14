//
//  CircleView.swift
//  Wallet
//
//  Created by Cake Technologies 27.09.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

protocol PinableView {
    func clear()
    func fill()
}

final class PinView: UIView, PinableView {
    private var circleShape: CAShapeLayer? = nil
    
    override func draw(_ rect: CGRect) {
        drawRingFittingInsideView()
    }
    
    private func drawRingFittingInsideView() {
        let halfSize: CGFloat = min(bounds.size.width / 2, bounds.size.height / 2)
        let desiredLineWidth: CGFloat = 1
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat(halfSize - (desiredLineWidth/2)),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)
        
        circleShape = CAShapeLayer()
        
        if let circleShape = circleShape {
            circleShape.path = circlePath.cgPath
            circleShape.fillColor = UIColor.clear.cgColor
            circleShape.strokeColor = UIColor.havenLightGrey.cgColor
            circleShape.lineWidth = desiredLineWidth
            
            layer.addSublayer(circleShape)
        }
    }
    
    func clear() {
        circleShape?.strokeColor = UIColor.havenLightGrey.cgColor
        circleShape?.fillColor = UIColor.clear.cgColor
    }
    
    func fill() {
        circleShape?.strokeColor = UIColor.havenGreen.cgColor
        circleShape?.fillColor = UIColor.havenGreen.cgColor
    }
}
