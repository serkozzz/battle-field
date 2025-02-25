//
//  AIController.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import Foundation

class AIController {
    
    private weak var aiPlayer: Player!
    private var field = Field.shared
    
    init(aiPlayer: Player) {
        self.aiPlayer = aiPlayer
    }
    
    func selectFighter() -> Fighter {
        aiPlayer.fighters.randomElement()!
    }
    
    func chooseMovementDestination(for fighter: Fighter) -> UUID {
        var sourceCell = Field.shared.cell(withFighter: fighter)!
        var sourceCoords = field.cellCoords(id: sourceCell)
        var j = sourceCoords.1 + ((sourceCoords.1 > 0) ? -1 : 1)
        return field.cells[sourceCoords.0][j].id
    }
}
