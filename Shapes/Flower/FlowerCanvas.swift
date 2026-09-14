//
//  CanvasDrawing.swift
//  Shapes
//
//  Created by David Paul Ong on 09/09/26.
//

import SwiftUI
import UniformTypeIdentifiers


struct FlowerFrameCanvas: View{
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
                    Flower.Leaves(rotation:rotation, a: 3, b: 15 * growth).draw(),
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
                Flower.Petals(rotation:rotation, r: 15 * growth, b: 6).draw(),
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

struct FlowerCanvas: View {
    let loop: Bool = true
    let FPS: CGFloat = 30
    let maxRotation: CGFloat = 180
    let maxGrowth: CGFloat = 1
    let maxFrames: Int = 140
    @State var frame: Int = 1
    
    var body: some View {
        GeometryReader { proxy in
            let center: CGPoint = .init(x: proxy.size.width/2, y: proxy.size.height/2)
            FlowerFrameCanvas(
                position: center,
                growth: getGrowth(frame: frame),
                rotation: getPetalRotation(frame: frame)
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
            // MARK: Use this to export
            exportGIF()
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

    func getPetalRotation(frame: Int) -> CGFloat{
        let currentRotation = maxRotation * CGFloat(frame) / CGFloat(maxFrames)
        let normalizedRotation = currentRotation / maxRotation
        let easedRotation = easeOut(t: Double(normalizedRotation))
        return CGFloat(easedRotation) * maxRotation
    }
    
    func getGrowth(frame: Int) -> CGFloat{
        let currentGrowth = 1 * Double(frame) / Double(maxFrames)
        let normalizedGrowth = currentGrowth / 1
        let easedGrowth = easeOut(t: Double(normalizedGrowth))
        return CGFloat(easedGrowth)
    }
    
    func easeOut(t: Double) -> Double{
        return 1 - pow(1-t, 2)
    }
    
    func exportImages(){
        
        // Get the default directory using the find manager.
        let fileManager = FileManager.default
        let directory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        
        // Delete all the files in the default directory
        if let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
        
        // Get every frame of animation
        for f in 1...maxFrames {
            let frame = FlowerFrameCanvas(
                position: CGPoint(x: 150, y: 150),
                growth: getGrowth(frame: f),
                rotation: getPetalRotation(frame: f)
            ).frame(width: 300, height: 300)
            // Make sure you specify a frame!!
            // It would draw an empty image otherwise.
            
            let renderer = ImageRenderer(content: frame)
            renderer.scale = 1
            if let uiImage = renderer.uiImage,
               let data = uiImage.pngData() {

                let url = directory.appendingPathComponent("flower-\(f).png")

                try? data.write(to: url)
                print(url.path)
            }

        }
        
    }
    
    func exportGIF() {
        let fileManager = FileManager.default

        let directory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        // Make sure the directory exists.
        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let url = directory.appendingPathComponent("flower.gif")

        // Remove existing GIF.
        try? fileManager.removeItem(at: url)

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.gif.identifier as CFString,
            maxFrames,
            nil
        ) else {
            print("Could not create GIF destination")
            return
        }

        // GIF settings
        let gifProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ]

        CGImageDestinationSetProperties(
            destination,
            gifProperties as CFDictionary
        )

        // Render every frame
        for f in 1...maxFrames {
            let frame = FlowerFrameCanvas(
                position: CGPoint(x: 150, y: 150),
                growth: getGrowth(frame: f),
                rotation: getPetalRotation(frame: f)
            )
            .frame(width: 300, height: 300)

            let renderer = ImageRenderer(content: frame)
            renderer.scale = 1

            guard let cgImage = renderer.cgImage else {
                print("Could not render frame \(f)")
                continue
            }

            // Frame duration: 1/30 second
            let frameProperties: [CFString: Any] = [
                kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: 1.0 / 30.0
                ]
            ]

            CGImageDestinationAddImage(
                destination,
                cgImage,
                frameProperties as CFDictionary
            )
        }

        // Finish writing GIF
        guard CGImageDestinationFinalize(destination) else {
            print("Could not finalize GIF")
            return
        }

        print("GIF saved to:")
        print(url.path)
    }


}

#Preview {
    FlowerCanvas()
    
}
