//
//  PuzzleView.swift
//  Shapes
//
//  Created by David Paul Ong on 12/09/26.
//

import SwiftUI
import UIKit

struct PuzzleView: View {
    
    let gridsize = 75.0
    let piecesConveyer = ["star", "star", "star", "star", "star", "star", "star", "star", "star"]
    
    var columns: [GridItem]
    init(){
        columns = [
            GridItem(.fixed(gridsize), spacing: 0),
            GridItem(.fixed(gridsize), spacing: 0),
            GridItem(.fixed(gridsize), spacing: 0),
        ]
    }
    
    
    var body: some View {
        // Grid
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(0..<9){ _ in
                Rectangle()
                    .frame(width: gridsize, height: gridsize)
                    .border(Color.white)
                    .dropDestination(for:String.self){ droppedItems, location in
                        print(droppedItems)
                        return true
                    }
            }
        }
        .background(.red)
        .padding(.horizontal, 10)
        
        // Puzzle Pieces
        HStack{
            ForEach(piecesConveyer, id: \.self){ item in
                Image(systemName: item)
                    .draggable(item)
            }
        }
        
        
    }
}

#Preview {
    PuzzleView()
}
