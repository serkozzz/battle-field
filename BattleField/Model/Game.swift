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
    func game(sender: Game, didTurnChange turn: Turn)
    func game(sender: Game, didPlayerMoveFrom startID: UUID, to destID: UUID)
    func game(sender: Game, didBattleStart battle: Battle)
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
            delegate?.game(sender: self, didTurnChange: turn)
        }
    }
    private var characterMover: CharacterMover!
    
    private lazy var field = GameContext.shared.field
    private lazy var player = GameContext.shared.player
    private lazy var aiPlayer = GameContext.shared.aiPlayer
    
    init() {
        (0..<field.rows).forEach{ _ in
            player.fighters.append(Fighter(imageColor: .blue))
            aiPlayer.fighters.append(Fighter(imageColor: .red))
        }
        field.placeFighters(playerFighters: player.fighters, enemyFighters: aiPlayer.fighters)
        
    }
    
    func toogleTurn() {
        turn = (turn == .player) ? .ai : .player
    }
    
    func cellState(id: UUID) -> CellState {
        if characterMover != nil {
            let fighter = field.cell(id: id).fighter
            if let fighter,
               player.fighters.contains(where: {$0 === fighter}) {
                return .normal
            }
            
            if characterMover.canMoveTo(cellID: id) {
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
        let sourceID = field.cell(withFighter: fighter)!
        let destCell = field.cell(id: destID)
        if (player.fighters.contains(where: {$0 === destCell.fighter })) {
            let sourceCell = field.cell(id: sourceID)
            let battle = Battle(playerFighter: destCell.fighter!, enemyFighter: sourceCell.fighter!)
            delegate?.game(sender: self, didBattleStart: battle)
            return
        }
        characterMover = CharacterMover(startCellID: sourceID, destinationCellID: destID)
        finishPlayerMovement()
    }
}

//MARK: Player Movement
extension Game {
    
    func isPlayerMovementActive() -> Bool {  return characterMover != nil }
    
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
        return characterMover.canMoveTo(cellID: cellID)
    }
    
    func startPlayerMovement(cellID: UUID) {
        characterMover = CharacterMover()
        characterMover.startMovement(cellID: cellID)
    }
    
    func setPlayerMovementDestinaiton(cellID: UUID?) { characterMover.setMovementDestinaiton(cellID: cellID) }
    
    func getPlayerMovementDestination() -> UUID? { characterMover?.movementDestination }
 
    func resetPlayerMovement() { characterMover = nil }
    
    func movePlayerToDestination() {
        let cellDest = field.cell(id: characterMover.movementDestination!)
        if aiPlayer.fighters.contains(where: { $0 === cellDest.fighter }) {
            let playerFighter = field.cell(id: characterMover.selectedCell!).fighter!
            let enemyFighter = field.cell(id: characterMover.movementDestination!).fighter!
            let battle = Battle(playerFighter: playerFighter, enemyFighter: enemyFighter)
            resetPlayerMovement()
            delegate?.game(sender: self, didBattleStart: battle)
        }
        else {
            finishPlayerMovement()
        }
    }
    
    private func finishPlayerMovement() {
        let path = (characterMover.selectedCell!, characterMover.movementDestination!)
        characterMover.moveToDestination()
        characterMover = nil
        delegate?.game(sender: self, didPlayerMoveFrom: path.0, to: path.1)
    }
}


//MARK: Battle
extension Game {
    
    func finishBattle(battle: Battle) {
        
        func removeFighter(player: Character, fighter: Fighter) {
            let cellID = field.cell(withFighter: fighter)!
            let (i,j) = field.cellCoords(id: cellID)
            player.fighters.removeAll(where: { $0 === fighter})
            field.cells[i][j].fighter = nil
        }
        

        if (turn == .player) {
            if (battle.winner === battle.playerFighter) {
                removeFighter(player: aiPlayer, fighter: battle.enemyFighter)
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
    
