//
//  ContentView.swift
//  Shapes
//
//  Created by David Paul Ong on 21/08/26.
//

import SwiftUI
internal import Combine


struct Trapezium: Shape{
    var offset: CGFloat = 0.5
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY * offset))
        path.closeSubpath()
        
        return path
    }
}


struct Superellipse: Shape {
    var n: CGFloat
    
    // Allows SwiftUI to smoothly animate the shape morphing
    var animatableData: CGFloat {
        get { n }
        set { n = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define our 'a' and 'b' axes based on the frame size
        let a = rect.width / 2
        let b = rect.height / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // The step size determines the smoothness of the curve.
        // pi/100 provides a smooth curve without tanking performance.
        let step = CGFloat.pi / 100
        
        for theta in stride(from: 0, to: 2 * CGFloat.pi, by: step) {
            let cosTheta = cos(theta)
            let sinTheta = sin(theta)
            
            // Apply the parametric formula
            // We use the ternary operator to handle the sign (sgn) function
            let xOffset = a * pow(abs(cosTheta), 2/n) * (cosTheta < 0 ? -1 : 1)
            let yOffset = b * pow(abs(sinTheta), 2/n) * (sinTheta < 0 ? -1 : 1)
            
            let point = CGPoint(x: center.x + xOffset, y: center.y + yOffset)
            
            if theta == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
        
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


struct FlowerShape: View{
    @State var rotation: CGFloat = 0
    
    var body: some View{
        
        ZStack{
            FlowerPetals(b: 6, rotation: rotation)
                .fill(.yellow)
                .frame(width: 200, height: 200)
                .onAppear {
                    withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            Circle()
                .fill(.orange)
                .frame(width: 40, height: 40)
                
        }
        .zIndex(2)
        
        ZStack{
            VStack(spacing: -6){
                ForEach(0..<3, id: \.self){i in
                    let rotation = CGFloat((i % 2 == 0) ? 0 : 180)
                    Folium(a: 15, rotation: rotation)
                        .fill(.green)
                        .frame(width: 100, height: 50)
                }
            }
            Rectangle()
                .fill(.brown)
                .frame(width: 6)
        }
        .offset(y: -120)
        .zIndex(1)
    }
}


struct SandBox: View {
    @State private var offset = 0.75
    @State private var n = 3.0
    @State private var r = 10.0
    
    var body: some View {
        ScrollView{
            VStack(spacing: 40) {
                FlowerShape()
                    .frame(width: 200, height: 200)
                Text("The Flower")
                    .font(.largeTitle)
                Slider(value: $r, in: 30...100)
                
                Superellipse(n: n)
                    .frame(width: 200, height: 200)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: n)
                Text("The Superellipse")
                    .font(.largeTitle)
                Slider(value: $n, in: 0.2...5)
                
                Button("Reset"){
                        n=2.0
                }
                Spacer()
                
            }
        }
        .padding()
    }
}

#Preview {
    SandBox()
}
