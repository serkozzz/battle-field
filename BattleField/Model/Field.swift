//
//  Field.swift
//  BattleField
//
//  Created by Sergey Kozlov on 22.02.2025.
//

import Foundation

private var FIELD_COLUMNS: Int = 10
private var FIELD_ROWS: Int = 5

class Field {
    static var shared = Field()
    
    private(set) var columns = FIELD_COLUMNS
    private(set) var rows = FIELD_ROWS
    
    var cells: [[Cell]]
    
    var flattenedCells: [Cell] {
        return cells.flatMap { $0 }
    }
    
    init() {
        cells = (0..<FIELD_ROWS).map { _ in
            (0..<FIELD_COLUMNS).map { _ in Cell() }}
        
        for i in 0..<FIELD_ROWS {
            cells[i][0].fighter = Fighter()
            cells[i][FIELD_COLUMNS - 1].fighter = Fighter()
        }
    }
    
    func cell(id: UUID) -> Cell {
        return flattenedCells.first { id == $0.id }!
    }
}
