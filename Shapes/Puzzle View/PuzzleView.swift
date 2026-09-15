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
    
    @State var gridIsTargeted: [Coordinate: Bool] = [:]
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
        var gridIsTargeted: [Coordinate: Bool] = [:]
        let images = cutImages(img: UIImage(named: "flower-140.png")!, size: PuzzleView.size).flatMap{$0} as! [UIImage]
        for column in 0..<PuzzleView.size {
            for row in 0..<PuzzleView.size {
                result.append(PuzzlePiece(solution: Coordinate(row: row, column: column)))
                pieceImageLookup[Coordinate(row: row, column: column)] = images[index]
                gridIsTargeted[Coordinate(row: row, column: column)] = false
                index += 1
            }
        }
        
        // Randomize
        /// @State properties need the underscore-prefixed assignment inside init:
        result.shuffle()
        self._pieces = State(initialValue: result)
        self._trayPieces = State(initialValue: result)
        self._gridIsTargeted = State(initialValue: gridIsTargeted)
    }
    
    var body: some View {
        if solved{
            FlowerCanvas()
        }
        else{
            VStack{
                // Grid
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(grid, id: \.coordinate){ g in
                        ZStack{
                            Rectangle()
                                .fill(gridIsTargeted[g.coordinate]! ? Color.blue.opacity(0.2) : Color.white)
                                .frame(width: PuzzleView.gridsize, height: PuzzleView.gridsize)
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
                                } isTargeted: { isTargeted in
                                    gridIsTargeted[g.coordinate] = isTargeted
                                }
                            if let solution = g.puzzlePiece?.solution,
                               let pieceImage = pieceImageLookup[solution] {
                                Image(uiImage: pieceImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: PuzzleView.gridsize, height: PuzzleView.gridsize)
                                    .draggable(g.puzzlePiece!)
                                    .dropDestination(for:PuzzlePiece.self){ droppedItems, location in
                                        guard let item = droppedItems.first else { return false}
                                        guard let droppedPiece = pieces.first(where: { $0.solution == item.solution }) else { return false}
                                        guard let droppedG = grid.first(where: { $0.coordinate == droppedPiece.coordinate }) else {return false}
                                        
                                        // update dropped piece values
                                        droppedG.puzzlePiece = g.puzzlePiece
                                        droppedPiece.coordinate = g.coordinate
                                        
                                        // update destination piece values
                                        let destinationPiece = g.puzzlePiece!
                                        g.puzzlePiece = droppedPiece
                                        destinationPiece.coordinate = droppedG.coordinate
                                        
                                        // check for solve
                                        if isSolved(){
                                            solved = true
                                        }
                                        return true
                                        
                                    }
                                    .background(Color.brown.opacity(0.1))
                            }
                        }
                    }
                }
                .frame(width: PuzzleView.gridsize * CGFloat(PuzzleView.size), height: PuzzleView.gridsize * CGFloat(PuzzleView.size))
                .border(Color.black)
                
                // Puzzle Pieces
                let trayColumns: [GridItem] = Array(
                    repeating: GridItem(.fixed(PuzzleView.trayMemberSize), spacing: 5),
                    count: 4
                )
                LazyVGrid(columns: trayColumns, spacing: 5) {
                    ForEach(trayPieces, id: \.solution) { piece in
                        let solution = piece.solution
                        if let pieceImage = pieceImageLookup[solution] {
                            Image(uiImage: pieceImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: PuzzleView.trayMemberSize, height: PuzzleView.trayMemberSize)
                                .draggable(piece)
                                .background(Color.brown.opacity(0.1))
                        }
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
