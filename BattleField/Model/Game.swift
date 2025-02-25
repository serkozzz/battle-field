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

    private let field = Field.shared
    private(set) var playerMotionManager = PlayerMotionManager()
    
    func cellState(id: UUID) -> CellState {
        if playerMotionManager.isActive {
            if id == playerMotionManager.selectedCell {
                return .normal
            }
            if playerMotionManager.canMoveTo(cellId: id) {
                return .accesable
            }
            return .forbidden
        }
        else {
            return .normal
        }
    }
}

//MARK: PlayerMotion
extension Game {
    func canStartMovement(cellID: UUID) -> Bool { playerMotionManager.canStartMovement(cellID: cellID) }
    
    mutating func startMovement(cellID: UUID) { playerMotionManager.startMovement(cellID: cellID) }
    
    func canMoveTo(cellId: UUID) -> Bool { playerMotionManager.canMoveTo(cellId: cellId) }
    
    mutating func cancelMovement() { playerMotionManager.cancelMovement() }
    
    mutating func moveTo(cellId: UUID) { playerMotionManager.moveTo(cellId: cellId)   }
    
    mutating func setMovementDestination(cellID: UUID) { playerMotionManager.setMovementDestinaiton(cellId: cellID) }
    
}
