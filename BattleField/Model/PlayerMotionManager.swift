//
//  FighterMover.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//
import Foundation

struct PlayerMotionManager {
   
    var isActive: Bool {
        selectedCell != nil
    }
    
    private(set) var selectedCell: UUID?
    private(set) var movementDestination: UUID?
    private let field = Field.shared
    private let stepDistance = 1
    
    func canStartMovement(cellID: UUID) -> Bool {
        field.cell(id: cellID).fighter != nil
    }
    
    mutating func startMovement(cellID: UUID) {
        selectedCell = cellID
    }
    
    func canMoveTo(cellId: UUID) -> Bool {
        if let selectedCell {
            
            let selectedCellCoords = field.cellCoords(id: selectedCell)
            let coords = field.cellCoords(id: cellId)
            if abs(coords.0 - selectedCellCoords.0) <= stepDistance && abs(coords.1 - selectedCellCoords.1) <= stepDistance {
                return true
            }
        }
        return false
    }
    
    mutating func setMovementDestinaiton(cellId: UUID) {
        movementDestination = cellId
    }
    
    mutating func cancelMovement() {
        selectedCell = nil
        movementDestination = nil
    }
    
    mutating func moveTo(cellId: UUID) {
        field.setFighter(to: cellId, fighter: field.cell(id: selectedCell!).fighter)
        field.setFighter(to: selectedCell!, fighter: nil)
        selectedCell = nil
        movementDestination = nil
    }
}
