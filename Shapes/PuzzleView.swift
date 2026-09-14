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
    var id = UUID()
    var coordinate: Coordinate?
    let solution: Coordinate
    
    init(coordinate: Coordinate? = nil, solution: Coordinate) {
        self.coordinate = coordinate
        self.solution = solution
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
    var pieceImageLookup: [Coordinate: UIImage] = [:]
    @State var pieces: [PuzzlePiece]
    init(){
        let images = cutImages(img: UIImage(named: "flower-140.png")!, size: 3).flatMap{$0} as! [UIImage]
        
        var index: Int = 0
        var result: [PuzzlePiece] = []
        for row in 0..<3 {
            for column in 0..<3 {
                result.append(PuzzlePiece(solution: Coordinate(row: row, column: column)))
                pieceImageLookup[Coordinate(row: row, column: column)] = images[index]
                index += 1
            }
        }
        pieces = result
    }
    
    @State var solved: Bool = false
    
    var body: some View {
        if solved{
            FlowerCanvas()
        }
        else{
            // Gridm
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
                                
                                // remove from piece conveyer
                                pieces = pieces.filter(){$0.id != piece.id}
                                
                                // check for solve
                                if isSolved(){
                                    solved = true
                                }
                                return true
                            }
                        if let solution = g.puzzlePiece?.solution,
                           let pieceImage = pieceImageLookup[solution] {
                            Image(uiImage: pieceImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: PuzzleView.gridsize, height: PuzzleView.gridsize)
                                .draggable(g.puzzlePiece!)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            
            // Puzzle Pieces
            HStack{
                ForEach(pieces, id: \.solution){ piece in
                    let solution = piece.solution
                    if let pieceImage = pieceImageLookup[solution]{
                        Image(uiImage: pieceImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .border(Color.black)
                            .draggable(piece)
                    }
                }
            }
        }
        
    }
    
    func isSolved() -> Bool {
        pieces.allSatisfy({$0.coordinate == $0.solution})
    }
}

#Preview {
    PuzzleView()
}
