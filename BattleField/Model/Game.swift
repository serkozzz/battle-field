//
//  Game.swift
//  BattleField
//
//  Created by Sergey Kozlov on 24.02.2025.
//

import Foundation

struct Game {
    enum CellState {
        case normal
        case accesable
        case forbidden
    }

    private(set) var selectedCell: UUID?
    private let field = Field.shared
    
    func cellState(id: UUID) -> CellState {
        if let _ = selectedCell {
            return .accesable
        }
        else {
            return .normal
        }
    }
    
    mutating func startMovement(cellID: UUID) {
        selectedCell = cellID
    }
    
    mutating func moveTo(cellId: UUID) {
        field.setFighter(to: cellId, fighter: field.cell(id: selectedCell!).fighter)
        field.setFighter(to: selectedCell!, fighter: nil)
        selectedCell = nil
    }

}
