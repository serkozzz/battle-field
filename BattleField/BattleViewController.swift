//
//  BattleViewController.swift
//  BattleField
//
//  Created by Sergey Kozlov on 28.02.2025.
//
import UIKit

protocol BattleViewControllerDelegate: AnyObject {
    func battleViewController(_ controller: BattleViewController, didFinish battle: Battle)
}


class BattleViewController : UIViewController, DialViewDelegate {
    private var battleModel: Battle!
    private var diceResult: Int!
    
    public weak var delegate: BattleViewControllerDelegate?
    
    @IBOutlet weak var dialView: DialView!
    
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var enemyImageView: UIImageView!
    
    required init?(coder: NSCoder, battleModel: Battle){
        super.init(coder: coder)
        self.battleModel = battleModel
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        let playerImage = UIImage(systemName: battleModel.playerFighter.imageName)
        playerImageView.image = playerImage
        
        let enemyImage = UIImage(systemName: battleModel.enemyFighter.imageName)
        enemyImageView.image = enemyImage
        enemyImageView.tintColor = .red
    }
    
    @IBAction func roll(_ sender: Any) {
        diceResult = Dice.random()
        dialView.delegate = self
        dialView.roll(to: diceResult)
        
    }
    
    func dialView(_ dialView: DialView, didRollFinished: Void) {
        let winner = battleModel.calculateWinner()
        let loserImageView = (winner === battleModel.playerFighter) ? enemyImageView: playerImageView
        UIView.animate(withDuration: 0.2, animations: {
            loserImageView?.tintColor = .clear
        }, completion: { [self] _ in
            
            let message = (winner === battleModel.playerFighter) ? "You win!": "You lose!"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [self] _ in
                delegate?.battleViewController(self, didFinish: battleModel)
            })
            present(alert, animated: true)
        })
    }
    
    
}
    
