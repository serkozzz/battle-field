//
//  AIController.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import Foundation

class AIController {
    
    private weak var aiPlayer: Character!
    private var field = GameContext.shared.field
    
    init(aiPlayer: Character) {
        self.aiPlayer = aiPlayer
    }
    
    func selectFighter() -> Fighter {
        aiPlayer.fighters.randomElement()!
    }
    
    func chooseMovementDestination(for fighter: Fighter) -> UUID {
        let sourceCell = field.cell(withFighter: fighter)!
        let sourceCoords = field.cellCoords(id: sourceCell)
        let j = sourceCoords.1 + ((sourceCoords.1 > 0) ? -Global.STEP_DISTANCE : Global.STEP_DISTANCE)
        return field.cells[sourceCoords.0][j].id
    }
}
