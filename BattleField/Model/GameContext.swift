//
//  GameContext.swift
//  BattleField
//
//  Created by Sergey Kozlov on 01.03.2025.
//

class GameContext {
    static var shared = GameContext()
    static func reset() {
        shared = GameContext()
    }
    let player = Character()
    let aiPlayer = Character()
    let field = Field()
}
