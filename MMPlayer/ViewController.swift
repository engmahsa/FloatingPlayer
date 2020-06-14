//
//  ViewController.swift
//  MMPlayer
//
//  Created by Mahsa Mo on 3/21/1399 AP.
//  Copyright © 1399 Mahsa Mo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var  playerContainerView: PlayerContainerView?
    
    @IBAction func presentPlayer(_ sender: Any) {
        self.playerContainerView = Bundle.main.loadNibNamed("videoPlayerContainerNib", owner: self, options: nil)?.first as? PlayerContainerView
        self.playerContainerView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(self.playerContainerView!)
        self.playerContainerView?.initializeView()
        self.playerContainerView?.minimizedOrigin = {
            let x = UIScreen.main.bounds.width/2
            let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32)
            let coordinate = CGPoint.init(x: x, y: y)
            return coordinate
        }()
        self.playerContainerView?.initializeView()
    }
}

