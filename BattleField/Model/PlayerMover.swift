//
//  FighterMover.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//
import Foundation

protocol PlayerMoverDelegate: AnyObject {
    func playerMover(sender: PlayerMover, didMovementFinished destination: UUID)
    func playerMover(sender: PlayerMover, didMovementStarted source: UUID )
}

class PlayerMover {
   
    var isActive: Bool {
        selectedCell != nil
    }
    
    weak var delegate: PlayerMoverDelegate?
    
    private(set) var selectedCell: UUID?
    private(set) var movementDestination: UUID?
    private let field = Field.shared
    private let stepDistance = 1
    
    private var player: Player
    init(player: Player) {
        self.player = player
    }
    
    func canStartMovement(game: Game, cellID: UUID) -> Bool {
        if game.turn == .player,
           let fighter = field.cell(id: cellID).fighter {
            return player.fighters.contains { $0 === fighter }
        }
        return false
    }
    
    func startMovement(cellID: UUID) {
        selectedCell = cellID
        delegate?.playerMover(sender: self, didMovementStarted: cellID)
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
    
    func setMovementDestinaiton(cellId: UUID) {
        movementDestination = cellId
    }
    
    func resetMovement() {
        selectedCell = nil
        movementDestination = nil
    }
    
    func moveTo(cellId: UUID) {
        field.stopNotification = true
        field.setFighter(to: cellId, fighter: field.cell(id: selectedCell!).fighter)
        field.setFighter(to: selectedCell!, fighter: nil)
        resetMovement()
        delegate?.playerMover(sender: self, didMovementFinished: cellId)
    }
}
