//
//  MainMenuViewController.swift
//  BattleField
//
//  Created by Sergey Kozlov on 01.03.2025.
//

import UIKit

class MainMenuViewController: UIViewController, BattleFieldViewControllerDelegate {
    
    @IBAction func start(_ sender: Any) {
        GameContext.reset()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let battleFieldVC = storyboard.instantiateViewController(withIdentifier: "BattleFieldViewController") as! BattleFieldViewController
        
        //battleFieldVC.modalTransitionStyle = .crossDissolve
        battleFieldVC.modalPresentationStyle = .fullScreen
        battleFieldVC.delegate = self
        
        present(battleFieldVC, animated: true)
    }
    
    func battleFieldViewController(_ viewController: BattleFieldViewController, didGameEnd winner: Character?) {
        dismiss(animated: true)
    }
}
