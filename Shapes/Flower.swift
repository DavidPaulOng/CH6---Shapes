//
//  Flower.swift
//  Shapes
//
//  Created by David Paul Ong on 09/09/26.
//

import Foundation
import SwiftUI

enum FlowerE{
    case Petals(rotation: CGFloat, r: CGFloat, b: CGFloat)
    case Leaves(rotation: CGFloat, a: CGFloat, b: CGFloat)
    
    func draw() -> Path{
        switch self{
        case .Petals(let rotation, let r, let b):
                var pencil = Path()
                let center = CGPoint(x: 0, y: 0)
                let samples = 100
                // the maximum radius of this equation is 3r.
                // the range of sin is [-1, 1]
                // the diameter is exactly 6r
                // which is how we get 6 to find the r                
                for i in 0...samples {
                    let rotationRadians = rotation * .pi / 180
                    let theta = CGFloat(i) * (2 * CGFloat.pi / CGFloat(samples))
                    let equationTheta = theta + rotationRadians
                    
                    let sinModifier = sin(theta * b)
                    let xOffset = r * (2 - sinModifier) * cos(equationTheta)
                    let yOffset = r * (2 - sinModifier) * sin(equationTheta)
                    
                    let point = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
                    
                    if theta == 0 {
                        pencil.move(to: point)
                    } else {
                        pencil.addLine(to: point)
                    }
                }
                pencil.closeSubpath()
                return pencil
        case .Leaves(let rotation, let a, let b):
            var pencil = Path()
            let samples = 100
            let center = CGPoint(x: 0, y: 0)
            
            for i in 0...samples {
                let rotationRadians = rotation * .pi / 180
                let theta = CGFloat(i) * (2 * CGFloat.pi / CGFloat(samples))
                let equationTheta = theta + rotationRadians
                
                // Polar Equation of a Folium
                let r = -b * cos(theta) + 4 * a * cos(theta) * pow(sin(theta), 2)
                let xOffset = r * cos(equationTheta)
                let yOffset = r * sin(equationTheta)
                
                let point = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
                
                if theta == 0 {
                    pencil.move(to: point)
                } else {
                    pencil.addLine(to: point)
                }
            }
            return pencil
        }
    }
}

struct FlowerPetals: Shape{
    var b: CGFloat
    var rotation: CGFloat
    
    init(b: CGFloat, rotation: CGFloat){
        self.b = b
        self.rotation = rotation
    }
    
    var animatableData: CGFloat {
        get { rotation }
        set { rotation = newValue }
    }
    func path(in rect: CGRect) -> Path{
        var pencil = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let samples = 100
        // the maximum radius of this equation is 3r.
        // the range of sin is [-1, 1]
        // the diameter is exactly 6r
        // which is how we get 6 to find the r
        let r = min(rect.width, rect.height) / 6
        
        for i in 0...samples {
            let rotationRadians = rotation * .pi / 180
            let theta = CGFloat(i) * (2 * CGFloat.pi / CGFloat(samples))
            let equationTheta = theta + rotationRadians
            
            let sinModifier = sin(theta * b)
            let xOffset = r * (2 - sinModifier) * cos(equationTheta)
            let yOffset = r * (2 - sinModifier) * sin(equationTheta)
            
            let point = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
            
            if theta == 0 {
                pencil.move(to: point)
            } else {
                pencil.addLine(to: point)
            }
        }
        pencil.closeSubpath()
        return pencil
    }
}

struct Folium: Shape {  
    var a: CGFloat
    var rotation: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var pencil = Path()
        let samples = 100
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let b = rect.width / 2 //Literally just got lucky finding this number idk why / 2 works.
        
        for i in 0...samples {
            let rotationRadians = rotation * .pi / 180
            let theta = CGFloat(i) * (2 * CGFloat.pi / CGFloat(samples))
            let equationTheta = theta + rotationRadians
            
            // Polar Equation of a Folium
            let r = -b * cos(theta) + 4 * a * cos(theta) * pow(sin(theta), 2)
            let xOffset = r * cos(equationTheta)
            let yOffset = r * sin(equationTheta)
            
            let point = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
            
            if theta == 0 {
                pencil.move(to: point)
            } else {
                pencil.addLine(to: point)
            }
        }
        return pencil
    }
}
