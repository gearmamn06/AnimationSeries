//
//  MyAnimationExtension.swift
//  AnimationSeries-Demo
//
//  Created by ParkHyunsoo on 18/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import AnimationSeries

extension UIView {
    
    public func move(path: [(CGPoint, AnimationParameter)]) -> AnimationSeries? {
        guard !path.isEmpty else { return nil }
        var sender: AnimationSeries!
        path.forEach { tp in
            if sender == nil {
                sender = self.move(position: tp.0, params: tp.1) + self.move(position: tp.0, params: AnimationParameter(0.0))
            }else{
                sender = sender + self.move(position: tp.0, params: tp.1)
            }
        }
        return sender
    }
    
}
