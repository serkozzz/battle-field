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
    func game(sender: Game, turnDidChange turn: Turn)
    func game(sender: Game, battleStarted battle: Battle)
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
    func moveAI(fighter: Fighter, to destID: UUID) {
        let sourceCellID = field.cell(withFighter: fighter)!
        var destCell = field.cell(id: destID)
        if (player.fighters.contains(where: {$0 === destCell.fighter })) {
            var sourceCell = field.cell(id: sourceCellID)
            let battle = Battle(playerFighter: destCell.fighter!, enemyFighter: sourceCell.fighter!)
            delegate?.game(sender: self, battleStarted: battle)
            return
        }
        
        field.setFighter(to: sourceCellID, fighter: nil)
        field.setFighter(to: destID, fighter: fighter)
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
        let cellDest = field.cell(id: playerMover.movementDestination!)
        if aiPlayer.fighters.contains(where: { $0 === cellDest.fighter }) {
            let playerFighter = field.cell(id: playerMover.selectedCell!).fighter!
            let enemyFighter = field.cell(id: playerMover.movementDestination!).fighter!
            let battle = Battle(playerFighter: playerFighter, enemyFighter: enemyFighter)
            delegate?.game(sender: self, battleStarted: battle)
        }
        else {
            playerMover.moveToDestination()
        }
    }
}


//MARK: Battle
extension Game {
    
    func finishBattle(battle: Battle) {
        
        func removeFighter(player: Player, fighter: Fighter) {
            let cellID = field.cell(withFighter: fighter)!
            let (i,j) = field.cellCoords(id: cellID)
            player.fighters.removeAll(where: { $0 === fighter})
            field.cells[i][j].fighter = nil
        }
        
        if (turn == .player) {
            if (battle.winner === battle.playerFighter) {
                removeFighter(player: aiPlayer, fighter: battle.enemyFighter)
                playerMover.moveToDestination()
            }
            else {
                removeFighter(player: player, fighter: battle.playerFighter)
            }
        }
        else {
            if (battle.winner === battle.playerFighter) {
                removeFighter(player: aiPlayer, fighter: battle.enemyFighter)
            }
            else {
                removeFighter(player: player, fighter: battle.playerFighter)
                //finish ai movement
            }
        }
    }
}
    
