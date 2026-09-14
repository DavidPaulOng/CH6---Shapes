//
//  PuzzleViewComponents.swift
//  Shapes
//
//  Created by David Paul Ong on 14/09/26.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import SwiftUI

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
