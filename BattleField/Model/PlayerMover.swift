//
//  FighterMover.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import Foundation


class CharacterMover {
    
    private(set) var selectedCell: UUID?
    private(set) var movementDestination: UUID?
    private let field = GameContext.shared.field
    private let stepDistance = 1
    
    init() { }
    
    init(startCellID: UUID, destinationCellID: UUID) {
        selectedCell = startCellID
        movementDestination = destinationCellID
    }
    
    func startMovement(cellID: UUID) {
        selectedCell = cellID
    }
    
    func canMoveTo(cellID: UUID) -> Bool {
        if let selectedCell {
            
            let selectedCellCoords = field.cellCoords(id: selectedCell)
            let coords = field.cellCoords(id: cellID)
            if abs(coords.0 - selectedCellCoords.0) <= stepDistance && abs(coords.1 - selectedCellCoords.1) <= stepDistance {
                return true
            }
        }
        return false
    }
    
    func setMovementDestinaiton(cellID: UUID?) {
        movementDestination = cellID
    }
    
    func moveToDestination() {
        field.setFighter(to: movementDestination!, fighter: field.cell(id: selectedCell!).fighter)
        field.setFighter(to: selectedCell!, fighter: nil)
    }
}
