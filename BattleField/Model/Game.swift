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
    func game(sender: Game, battleStarted: Battle)
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
    private var playerMover = PlayerMover()
    
    private(set) var player = Player()
    private(set) var aiPlayer = Player()
    private let field = Field.shared
    
    init() {
        (0..<field.rows).forEach{ _ in
            player.fighters.append(Fighter(imageColor: .blue))
            aiPlayer.fighters.append(Fighter(imageColor: .red))
        }
        field.placeFighters(playerFighters: player.fighters, enemyFighters: aiPlayer.fighters)
        
    }
    
    func cellState(id: UUID) -> CellState {
        if playerMover.isActive {
            let fighter = field.cell(id: id).fighter
            if let fighter,
               player.fighters.contains(where: {$0 === fighter}) {
                return .normal
            }
            
            if playerMover.canMoveTo(cellID: id) {
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

//MARK: Player Movement
extension Game {
    
    func isPlayerMovementActive() -> Bool {  return playerMover.isActive }
    
    func canStartPlayerMovement(cellID: UUID) -> Bool {
        if let fighter = field.cell(id: cellID).fighter {
            return player.fighters.contains { $0 === fighter }
        }
        return false
    }
    
    func canMovePlayer(to cellID: UUID) -> Bool {
        if let fighter = field.cell(id: cellID).fighter,
           player.fighters.contains(where: { $0 === fighter }) {
            return false
        }
        return playerMover.canMoveTo(cellID: cellID)
    }
    
    func startPlayerMovement(cellID: UUID) { playerMover.startMovement(cellID: cellID) }
    
    func setPlayerMovementDestinaiton(cellID: UUID?) { playerMover.setMovementDestinaiton(cellID: cellID) }
    
    func getPlayerMovementDestination() -> UUID? { playerMover.movementDestination }
 
    func resetPlayerMovement() { playerMover.resetMovement() }
    
    func movePlayerToDestination() {
        var cellDest = field.cell(id: playerMover.movementDestination!)
        if aiPlayer.fighters.contains(where: { $0 === cellDest.fighter }) {
            var playerFighter = field.cell(id: playerMover.selectedCell!).fighter!
            var enemyFighter = field.cell(id: playerMover.movementDestination!).fighter!
            var battle = Battle(playerFighter: playerFighter, enemyFighter: enemyFighter)
            delegate?.game(sender: self, battleStarted: battle)
        }
        else {
            playerMover.moveToDestination()
        }
    }
}
