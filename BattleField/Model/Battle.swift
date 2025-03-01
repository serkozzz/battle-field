//
//  Battle.swift
//  BattleField
//
//  Created by Sergey Kozlov on 27.02.2025.
//

struct Battle {
    var playerFighter: Fighter
    var enemyFighter: Fighter
    var winner: Fighter?
    
    var diceResult: Int?
    
    mutating func rollDice() -> Int {
        diceResult = Dice.random()
        return diceResult!
    }
    
    mutating func calculateWinner() -> Fighter {
        winner = (diceResult! < 4) ? playerFighter : enemyFighter
        //winner = playerFighter
        return winner!
    }
}
