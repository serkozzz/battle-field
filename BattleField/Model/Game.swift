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
    private let stepDistance = 1
    
    func cellState(id: UUID) -> CellState {
        if let selectedCell {
            if id == selectedCell {
                return .normal
            }
            
            let selectedCellCoords = field.cellCoords(id: selectedCell)
            let coords = field.cellCoords(id: id)
            if abs(coords.0 - selectedCellCoords.0) <= stepDistance && abs(coords.1 - selectedCellCoords.1) <= stepDistance {
                return .accesable
            }
            return .forbidden
        }
        else {
            return .normal
        }
    }
    
    func canStartMovement(cellID: UUID) -> Bool {
        field.cell(id: cellID).fighter != nil
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
