//
//  PuzzleView.swift
//  Shapes
//
//  Created by David Paul Ong on 12/09/26.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct Coordinate: Hashable, Codable {
    let row: Int
    let column: Int
}

@Observable
class GridElement: Identifiable{
    let coordinate: Coordinate
    var puzzlePiece: PuzzlePiece?
    
    init(coordinate: Coordinate, puzzlePiece: PuzzlePiece? = nil) {
        self.coordinate = coordinate
        self.puzzlePiece = puzzlePiece
    }
}

@Observable
class PuzzlePiece: Identifiable, Codable, Transferable{
    var coordinate: Coordinate?
    let image: String
    
    init(coordinate: Coordinate? = nil, image: String) {
        self.coordinate = coordinate
        self.image = image
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .puzzlePiece!)
    }
    
}

extension UTType {
    static let puzzlePiece = UTType("com.davidpaulong.Shapes")
}

struct PuzzleView: View {
    
    static let gridsize = 75.0
    var columns: [GridItem] = [
        GridItem(.fixed(gridsize), spacing: 0),
        GridItem(.fixed(gridsize), spacing: 0),
        GridItem(.fixed(gridsize), spacing: 0)
    ]
    @State var grid: [GridElement] = (0..<3).flatMap { row in
        (0..<3).map { column in
            GridElement(
                coordinate: .init(row: row, column: column)
            )
        }
    }

    let pieces = ["star", "star", "star", "star", "star", "star", "star", "star", "star"]
    let pieces2 = [
        PuzzlePiece(
            image: "star"
        ),
        PuzzlePiece(
            image: "square.and.arrow.uptar"
        ),PuzzlePiece(
            image: "pencil"
        )
    ]
    
    var body: some View {
        // Grid
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(grid, id: \.coordinate){ g in
                ZStack{
                    Rectangle()
                        .frame(width: PuzzleView.gridsize, height: PuzzleView.gridsize)
                        .border(Color.white)
                        .dropDestination(for:PuzzlePiece.self){ droppedItems, location in
                            
                            guard let piece = droppedItems.first else { return false}
                            
                            // clear the puzzle piece's previous position
                            if let previousG = grid.first(where: { $0.coordinate == piece.coordinate }) {
                                previousG.puzzlePiece = nil
                            }
                            
                            // assign piece to the grid element
                            g.puzzlePiece = piece
                            
                            // assign new grid element coordinate to piece
                            piece.coordinate = g.coordinate
                            
                            return true
                        }
                    if let pieceImage = g.puzzlePiece?.image{
                        Image(systemName: pieceImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: PuzzleView.gridsize, height: PuzzleView.gridsize)
                            .background(Color.yellow)
                            .draggable(g.puzzlePiece!)
                    }
                }
            }
        }
        .background(.red)
        .padding(.horizontal, 10)
        
        // Puzzle Pieces
        HStack{
            ForEach(pieces2, id: \.image){ piece in
                Image(systemName: piece.image)
                    .draggable(piece)
            }
        }
        
        
    }
}

#Preview {
    PuzzleView()
}
