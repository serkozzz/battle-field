//
//  ViewController.swift
//  BattleField
//
//  Created by Sergey Kozlov on 22.02.2025.
//

import UIKit

class BattleFieldViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    
    var game = Game()
    var aiController: AIController!
   
    var aiMotionAnimator: FighterMovementAnimator!
    var dropAnimator: UIDragAnimating!
    
    var field = GameContext.shared.field
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.delegate = self
        aiController = AIController(aiPlayer: GameContext.shared.aiPlayer)
                
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(BattleFieldCollectionCell.self, forCellWithReuseIdentifier: BattleFieldCollectionCell.reuseID)
        
        collectionView.dragInteractionEnabled = true // Включить drag
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        // Do any additional setup after loading the view.
        dataSource = createDataSource()
        applySnapshot()
        
        aiMotionAnimator = FighterMovementAnimator(collectionView: collectionView, diffableDataSource: dataSource)
    }

    @IBAction func aiTurn(_ sender: Any) {
        game.toogleTurn()
    }
}


extension BattleFieldViewController: GameDelegate {
    
    func game(sender: Game, didTurnChange turn: Turn) {
        if (turn == .ai) {
            makeAITurn()
        }
    }
    
    func game(sender: Game, didPlayerMoveFrom startID: UUID, to destID: UUID) {
        let items = (game.turn == .player) ? dataSource.snapshot().itemIdentifiers : [startID, destID]
        reloadSnapshot(items: items, animating: false)
        
        if (game.turn == .player && dropAnimator != nil) {
            dropAnimator.addCompletion { [weak self] _ in
                self?.game.toogleTurn()
            }
            dropAnimator = nil
        }
        else {
            game.toogleTurn()
        }
    }
    
    func game(sender: Game, didBattleStart battle: Battle) {
        let storyboard = UIStoryboard(name: "Battle", bundle: nil)
        let battleVC = storyboard.instantiateInitialViewController { coder in
            return BattleViewController(coder: coder, battleModel: battle)
        }
        battleVC?.delegate = self
        battleVC?.modalPresentationStyle = .fullScreen
        present(battleVC!, animated: true)
    }

    
    func makeAITurn() {
        //reloadSnapshot()
        let fighter = aiController.selectFighter()
        let dest = aiController.chooseMovementDestination(for: fighter)
        aiMotionAnimator.animateMovement(fighter: fighter, to: dest) { [weak self] in
            self?.game.moveAI(fighter: fighter, to: dest)
        }
    }
    
}


extension BattleFieldViewController: BattleViewControllerDelegate {
    func battleViewController(_ controller: BattleViewController, didFinish battle: Battle) {
        controller.dismiss(animated: true) { [self] in
            
            let playerCellID = field.cell(withFighter: battle.playerFighter)!
            let enemyCellID = field.cell(withFighter: battle.enemyFighter)!
            game.finishBattle(battle: battle)
            
            func finishMovementIfNeeded() -> Bool {
                if (game.turn == .player && battle.winner === battle.playerFighter) {
                    game.startFighterMovement(cellID: playerCellID)
                    game.setFighterMovementDestinaiton(cellID: enemyCellID)
                    game.moveFighterToDestination()
                    return true
                }
                if (game.turn == .ai && battle.winner === battle.enemyFighter) {
                    game.startFighterMovement(cellID: enemyCellID)
                    game.setFighterMovementDestinaiton(cellID: playerCellID)
                    game.moveFighterToDestination()
                    return true
                }
                return false
            }

            if (!finishMovementIfNeeded()){
                reloadSnapshot()
                game.toogleTurn()
            }
        }
    }
}


