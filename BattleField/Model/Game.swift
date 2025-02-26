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

class Game {
    
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
    func playerMover(sender: PlayerMover, didMovementFinished destination: UUID) {
        field.stopNotification = true
        (0..<field.rows).forEach { i in
            (0..<field.columns).forEach{ j in field.cells[i][j].state = .normal }}
        field.stopNotification = false
        field.cellsChanged.send()
        turn = .ai
    }
    
    func playerMover(sender: PlayerMover, didMovementStarted source: UUID) {
        field.stopNotification = true
        (0..<field.rows).forEach { i in
            (0..<field.columns).forEach{ j in
                let cellID = field.cells[i][j].id
                if (cellID == playerMover.selectedCell) {
                    field.cells[i][j].state = .normal
                }
                else if (playerMover.canMoveTo(cellId: cellID)) {
                    field.cells[i][j].state = .accesable
                }
                else {
                    field.cells[i][j].state = .forbidden
                }
            }
        }
        field.stopNotification = false
        field.cellsChanged.send()
    }
}
