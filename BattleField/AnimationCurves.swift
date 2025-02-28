//
//  AnimationCurves.swift
//  BattleField
//
//  Created by Sergey Kozlov on 28.02.2025.
//

import Foundation


//interpolation by 2 points: (0,0) and (x,y)
//it is so cool that you need calculate only one factor(a) to get math func passing trough (0,0) and particular (x,y)
//when apply it for animation - x is time
protocol AnimationCurveFunction {
    func y(x: Float) -> Float
    init(asInterpolationWith point: CGPoint)
}

struct SqrtFunction: AnimationCurveFunction {
    //y = a * sqrt(x)
    
    var a: Float
    
    init(asInterpolationWith point: CGPoint) {
        a = Float(point.y / sqrt(point.x))
    }
    
    func y(x: Float) -> Float {
        return a * sqrt(x)
    }
}

struct LinearFunction: AnimationCurveFunction {
    //y = a * x
    
    var a: Float
    
    init(asInterpolationWith point: CGPoint) {
        a = Float(point.y / point.x)
    }
    
    func y(x: Float) -> Float {
        return a * x
    }
}
