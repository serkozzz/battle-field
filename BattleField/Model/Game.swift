//
//  Game.swift
//  BattleField
//
//  Created by Sergey Kozlov on 24.02.2025.
//

import Foundation

struct Game {
    enum CellState {
        case normal
        case accesable
        case forbidden
    }

    var selectedCell: Cell?
    
    func cellState(id: UUID) -> CellState {
        if let selectedCell {
            return .accesable
        }
        else {
            return .normal
        }
    }

}
