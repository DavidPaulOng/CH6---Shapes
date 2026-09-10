//
//  Curved Rectangle.swift
//  Shapes
//
//  Created by David Paul Ong on 22/08/26.
//

import SwiftUI


struct CurvedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x:rect.maxX, y: 0))
        path.addLine(to: CGPoint(x:rect.maxX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.maxY + 20))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    CurvedRectangle()
        .cornerRadius(20)
        .frame(width: 300, height: 300)
}
