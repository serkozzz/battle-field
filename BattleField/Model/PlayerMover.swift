//
//  FighterMover.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import Foundation


class PlayerMover {
   
    var isActive: Bool {
        selectedCell != nil
    }
    
    private(set) var selectedCell: UUID?
    private(set) var movementDestination: UUID?
    private let field = Field.shared
    private let stepDistance = 1
    
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
    
    func setMovementDestinaiton(cellID: UUID) {
        movementDestination = cellID
    }
    
    func resetMovement() {
        selectedCell = nil
        movementDestination = nil
    }
    
    func moveToDestination() {
        field.setFighter(to: movementDestination!, fighter: field.cell(id: selectedCell!).fighter)
        field.setFighter(to: selectedCell!, fighter: nil)
        resetMovement()
    }
}
