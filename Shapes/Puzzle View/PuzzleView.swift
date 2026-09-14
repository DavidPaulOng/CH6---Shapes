//
//  PuzzleView.swift
//  Shapes
//
//  Created by David Paul Ong on 12/09/26.
//

import SwiftUI

struct PuzzleView: View {
    static let gridsize = 75.0
    static let trayMemberSize = 50.0
    static let size = 2
    
    var pieceImageLookup: [Coordinate: UIImage] = [:]
    var columns: [GridItem] = Array(
        repeating: GridItem(.fixed(gridsize), spacing: 0),
        count: size
    )

    @State var pieces: [PuzzlePiece]
    @State var trayPieces: [PuzzlePiece]
    @State var solved: Bool = false
    @State var grid: [GridElement] = (0..<size).flatMap { row in
        (0..<size).map { column in
            GridElement(coordinate: .init(row: row, column: column))
        }
    }
    
    init(){
        var index: Int = 0
        var result: [PuzzlePiece] = []
        let images = cutImages(img: UIImage(named: "flower-140.png")!, size: PuzzleView.size).flatMap{$0} as! [UIImage]
        for column in 0..<PuzzleView.size {
            for row in 0..<PuzzleView.size {
                result.append(PuzzlePiece(solution: Coordinate(row: row, column: column)))
                pieceImageLookup[Coordinate(row: row, column: column)] = images[index]
                index += 1
            }
        }
        
        // Randomize
        /// @State properties need the underscore-prefixed assignment inside init:
        result.shuffle()
        self._pieces = State(initialValue: result)
        self._trayPieces = State(initialValue: result)
    }
    
    var body: some View {
        if solved{
            FlowerCanvas()
        }
        else{
            // Grid
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(grid, id: \.coordinate){ g in
                    ZStack{
                        Rectangle()
                            .frame(width: PuzzleView.gridsize, height: PuzzleView.gridsize)
                            .border(Color.white)
                            .dropDestination(for:PuzzlePiece.self){ droppedItems, location in
                                // The dropped piece is not the live object sitting in your pieces array.
                                guard let droppedPiece = droppedItems.first else { return false}
                                guard let piece = pieces.first(where: { $0.solution == droppedPiece.solution }) else { return false}
                                
                                // clear the puzzle piece's previous position
                                if let previousG = grid.first(where: { $0.coordinate == piece.coordinate }) {
                                    previousG.puzzlePiece = nil
                                }
                                
                                // assign piece to the grid element
                                g.puzzlePiece = piece
                                
                                // assign new grid element coordinate to piece
                                piece.coordinate = g.coordinate
                                
                                // remove from piece conveyer
                                trayPieces = trayPieces.filter(){$0.id != piece.id}
                                
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
            let trayColumns: [GridItem] = Array(
                repeating: GridItem(.fixed(PuzzleView.trayMemberSize), spacing: 0),
                count: 4
            )
            LazyVGrid(columns: trayColumns, spacing: 0) {
                ForEach(trayPieces, id: \.solution) { piece in
                    let solution = piece.solution
                    if let pieceImage = pieceImageLookup[solution] {
                        Image(uiImage: pieceImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: PuzzleView.trayMemberSize, height: PuzzleView.trayMemberSize)
                            .border(Color.black)
                            .draggable(piece)
                    }
                }
            }
        }
        
    }
    
    func isSolved() -> Bool {
        return pieces.allSatisfy({$0.coordinate == $0.solution})
    }
}

#Preview {
    PuzzleView()
}
