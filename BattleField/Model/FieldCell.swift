//
//  Cell.swift
//  BattleField
//
//  Created by Sergey Kozlov on 22.02.2025.
//
import Foundation

struct FieldCell {
    enum CellState {
        case normal
        case accesable
        case forbidden
    }
    
    var state: CellState = .normal
    var fighter: Fighter?
    var id = UUID()
}
