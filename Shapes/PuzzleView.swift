//
//  PuzzleView.swift
//  Shapes
//
//  Created by David Paul Ong on 12/09/26.
//

import SwiftUI
import UIKit

@Observable
class GridElement: Identifiable{
    let coordinate: Coordinate
    var isOccupied: Bool = false
    var occupiedBy: String?
    
    init(coordinate: Coordinate, isOccupied: Bool = false, occupiedBy: String? = nil) {
        self.coordinate = coordinate
        self.isOccupied = isOccupied
        self.occupiedBy = occupiedBy
    }
    
    struct Coordinate: Hashable {
        let row: Int
        let column: Int
    }
}

struct PuzzleView: View {
    
    let gridsize = 75.0
    var columns: [GridItem]
    var grid: [GridElement] = (0..<3).flatMap { row in
        (0..<3).map { column in
            GridElement(
                coordinate: .init(row: row, column: column)
            )
        }
    }

    let piecesConveyer = ["star", "star", "star", "star", "star", "star", "star", "star", "star"]
    
    
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
            ForEach(grid, id: \.coordinate){ gElement in
                ZStack{
                    Rectangle()
                        .frame(width: gridsize, height: gridsize)
                        .border(Color.white)
                        .dropDestination(for:String.self){ droppedItems, location in
                            gElement.isOccupied = true
                            gElement.occupiedBy = droppedItems.first
                            return true
                        }
                    if let occupiedBy = gElement.occupiedBy{
                        Image(systemName: occupiedBy)
                            .resizable()
                            .scaledToFit()
                            .frame(width: gridsize, height: gridsize)
                            .background(Color.yellow)
                    }
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
