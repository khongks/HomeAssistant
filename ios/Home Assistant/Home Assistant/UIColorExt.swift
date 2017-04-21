//
//  UIColorExt.swift
//  Home Assistant
//
//  Created by khongks on 16/4/17.
//  Copyright © 2017 spocktech. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  convenience init(R: Int, G: Int, B: Int) {
    let newRed = CGFloat(R)/255
    let newGreen = CGFloat(G)/255
    let newBlue = CGFloat(B)/255
    
    self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
  }
}
