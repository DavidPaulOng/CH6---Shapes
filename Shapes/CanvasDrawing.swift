//
//  CanvasDrawing.swift
//  Shapes
//
//  Created by David Paul Ong on 09/09/26.
//

import SwiftUI

struct FrameCanvas: View{
    let position: CGPoint
    let growth: CGFloat
    let rotation: CGFloat
    
    var body: some View{
        Canvas { context, size in
            
            // Variables
            let height = 100 * growth
            
            // Foliums
            context.transform.tx = position.x
            context.transform.ty =  position.y - height
            context.transform.ty += CGFloat(20 * growth)
            for i in 1...3 {
                context.transform.ty += CGFloat(20 * growth)
                let rotation = CGFloat((i % 2 == 0) ? 0 : 180)
                context.fill(
                    FlowerE.Leaves(rotation:rotation, a: 3, b: 15 * growth).draw(),
                    with: .color(.green)
                )
            }
            
            // Stem
            context.transform.ty = position.y - height
            context.fill(
                Rectangle().path(in: CGRect(x: -(7 * growth / 2), y: 0, width: 7 * growth, height: height)),
                with: .color(.brown)
            )
            
            // Petals
            context.fill(
                FlowerE.Petals(rotation:rotation, r: 15 * growth, b: 6).draw(),
                with: .color(.yellow)
            )
            
            // Crown Center
            context.fill(
                Circle().path(in: CGRect(x: -(12 * growth / 2), y: -(12 * growth / 2), width: 12 * growth, height: 12 * growth)),
                with: .color(.orange)
            )
            
        }
    }
}

struct CanvasDrawing: View {
    let loop: Bool = true
    let FPS: CGFloat = 30
    let maxRotation: CGFloat = 180
    let maxGrowth: CGFloat = 1
    let maxFrames: Int = 140
    @State var frame: Int = 1
    
    var body: some View {
        GeometryReader { proxy in
            let center: CGPoint = .init(x: proxy.size.width/2, y: proxy.size.height/2)
            FrameCanvas(
                position: center,
                growth: getGrowth(),
                rotation: getPetalRotation()
            )
        }
        .frame(width: 300, height: 300)
        .onAppear{
            Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { _ in
                frame += 1
                if frame > self.maxFrames {
                    self.frame = 1
                }
            }
        }
        
        Slider(
            value: Binding(
                get: { Double(frame) },
                set: { frame = Int($0)}
            ),
            in: 1...Double(maxFrames),
            step: 1
        )
        .padding(20)
    }

    func getPetalRotation() -> CGFloat{
        let currentRotation = maxRotation * CGFloat(frame) / CGFloat(maxFrames)
        let normalizedRotation = currentRotation / maxRotation
        let easedRotation = easeOut(t: Double(normalizedRotation))
        return CGFloat(easedRotation) * maxRotation
    }
    
    func getGrowth() -> CGFloat{
        let currentGrowth = 1 * Double(frame) / Double(maxFrames)
        let normalizedGrowth = currentGrowth / 1
        let easedGrowth = easeOut(t: Double(normalizedGrowth))
        return CGFloat(easedGrowth)
    }
    
    func easeOut(t: Double) -> Double{
        return 1 - pow(1-t, 2)
    }
    
    func convertToImage() -> some View{
        let renderer = ImageRenderer(content: CanvasDrawing())
        if let image = renderer.uiImage {
            return Image(uiImage: image)
        }
        return (Image(systemName: "xmark.circle"))
    }

}

#Preview {
    CanvasDrawing()
    
}
