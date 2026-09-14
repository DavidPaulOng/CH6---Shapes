//
//  ImageConversion.swift
//  Shapes
//
//  Created by David Paul Ong on 10/09/26.
//

import SwiftUI

struct ImageConversion: View {
    
    var body: some View {
        Image("flower-140")
            .resizable()
            .frame(width: 150, height: 150)
            .border(Color.black)
        let images = cutImages(img: UIImage(named: "flower-140.png")!, size: 4)
        ScrollView{
            VStack{
                ForEach(images, id: \.self){column in
                    ForEach(column, id: \.self){row in
                        Image(uiImage: row!)
                            .border(Color.black)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    ImageConversion()
}

func cutImages(img: UIImage, size: Int) -> [[UIImage?]]{
    var images: [[UIImage?]] = Array(
        repeating: Array(repeating: nil, count: size),
        count: size
    )
    
    let width = img.size.width/CGFloat(size)
    let height = img.size.height/CGFloat(size)
    var xstep = 0.0
    var ystep = 0.0
    for x in 1...size{
        ystep = 0.0
        for y in 1...size{
            let cropzone = CGRect(x: xstep, y: ystep, width:width, height:height)
            print(xstep, ystep)
            // Perform cropping in Core Graphics
            guard let cutImageRef: CGImage = img.cgImage?.cropping(to:cropzone)
            else {
                print("Image Cropping Failed")
                return images
            }
            let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
            images[x-1][y-1] = croppedImage
            ystep += width
        }
        xstep += width
    }
    
    return images
}
