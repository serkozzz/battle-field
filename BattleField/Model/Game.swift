//
//  Game.swift
//  BattleField
//
//  Created by Sergey Kozlov on 24.02.2025.
//

import Foundation

struct Game {
    
    enum Turn {
        case player
        case ai
    }
    
    enum CellState {
        case normal
        case accesable
        case forbidden
    }
    
    private(set) var playerMover: PlayerMover!
    
    private let field = Field.shared
    private(set) var player = Player()
    private(set) var aiPlayer = Player()
    
    init() {
        (0..<field.rows).forEach{ _ in
            player.fighters.append(Fighter())
            aiPlayer.fighters.append(Fighter())
        }
        field.placeFighters(playerFighters: player.fighters, enemyFighters: aiPlayer.fighters)
        
        playerMover = PlayerMover(player: player)
    }
    
    func cellState(id: UUID) -> CellState {
        if playerMover.isActive {
            if id == playerMover.selectedCell {
                return .normal
            }
            if playerMover.canMoveTo(cellId: id) {
                return .accesable
            }
            return .forbidden
        }
        else {
            return .normal
        }
    }
}


//MARK: AIMotion
extension Game {
    mutating func moveAI(fighter: Fighter, to destination: UUID) {
        var sourceCell = field.cell(withFighter: fighter)!
        field.setFighter(to: sourceCell, fighter: nil)
        field.setFighter(to: destination, fighter: fighter)
    }
}
