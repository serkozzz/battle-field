//
//  Game.swift
//  BattleField
//
//  Created by Sergey Kozlov on 24.02.2025.
//

import Foundation

enum Turn {
    case player
    case ai
}

protocol GameDelegate: AnyObject {
    func game(sender: Game, turnDidChange: Turn)
}

class Game  {
        
    enum CellState {
        case normal
        case accesable
        case forbidden
    }
    
    weak var delegate: GameDelegate?
    
    var turn: Turn = .player {
        didSet {
            delegate?.game(sender: self, turnDidChange: turn)
        }
    }
    private(set) var playerMover: PlayerMover!
    
    private(set) var player = Player()
    private(set) var aiPlayer = Player()
    private let field = Field.shared
    
    init() {
        (0..<field.rows).forEach{ _ in
            player.fighters.append(Fighter())
            aiPlayer.fighters.append(Fighter())
        }
        field.placeFighters(playerFighters: player.fighters, enemyFighters: aiPlayer.fighters)
        
        playerMover = PlayerMover(player: player)
        playerMover.delegate = self
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
    func moveAI(fighter: Fighter, to destination: UUID) {
        let sourceCell = field.cell(withFighter: fighter)!
        field.setFighter(to: sourceCell, fighter: nil)
        field.setFighter(to: destination, fighter: fighter)
        turn = .player
    }
}


extension Game: PlayerMoverDelegate {
    func playerMover(sender: PlayerMover, didMoveTo destination: UUID) {
        turn = .ai
    }
    
}
