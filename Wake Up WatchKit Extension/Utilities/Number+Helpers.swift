//
//  Comparable+Helpers.swift
//  Wake Up WatchKit Extension
//
//  Created by Zihan Qi on 5/5/20.
//  Copyright © 2020 Zihan Qi. All rights reserved.
//

import Foundation
import CoreGraphics

extension Comparable {
    /// Returns a clamped value for `self` that is bounded by `min` and `max`.
    func clamped(min: Self, max: Self) -> Self {
        guard min <= max else { fatalError("min cannot be larger than max.") }
        if self > max {
            return max
        } else if self < min {
            return min
        } else {
            return self
        }
    }
}

func cubicBezierCurve(c0x: Double, c0y: Double, c1x: Double, c2y: Double) -> (CGFloat) -> CGFloat {
    let curve = { (t: CGFloat) -> CGFloat in
        let a = 3 * (1-t) * (1-t) * t * CGFloat(c0x)
        let b = 3 * (1-t) * t * t * CGFloat(c1x)
        let c = t * t * t
        return a + b + c
    }
    return curve
}

enum AnimationCurve {
    case easeInOut
    case easeIn
    case easeOut
    case linear
    
    var timingFunction: (CGFloat) -> CGFloat {
        switch self {
        case .easeInOut:
            return cubicBezierCurve(c0x: 0.42, c0y: 0, c1x: 0.58, c2y: 1)
        case .easeIn:
            return cubicBezierCurve(c0x: 0.42, c0y: 0, c1x: 1, c2y: 1)
        case .easeOut:
            return cubicBezierCurve(c0x: 0, c0y: 0, c1x: 0.58, c2y: 1)
        case .linear:
            return cubicBezierCurve(c0x: 0, c0y: 0, c1x: 1, c2y: 1)
        }
    }
}

extension CGFloat {
    /// Maps the current value to a new value using the specified animation curve.
    func interpolated(using curve: AnimationCurve) -> Self {
        curve.timingFunction(self)
    }
}
