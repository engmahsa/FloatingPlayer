//
//  CustomSlider.swift
//  Telewebion
//
//  Created by Mahsa Mo on 22.10.18.
//  Copyright © 2018 Mahsa Mo. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    override func draw(_ rect: CGRect) {
        // Drawing code
        self.setThumbImage(UIImage(named:"slider"), for: UIControl.State.normal)
        self.tintColor = UIColor.white
        self.minimumTrackTintColor = .red
        self.maximumTrackTintColor = UIColor.white
        self.minimumValue = 0
        self.isContinuous = true
    }
 
    @IBInspectable var trackHeight: CGFloat = 2
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
    }
}
