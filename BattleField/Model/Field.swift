//
//  Field.swift
//  BattleField
//
//  Created by Sergey Kozlov on 22.02.2025.
//

import Foundation


class Field {
    
    private(set) var columns = Global.FIELD_COLUMNS
    private(set) var rows = Global.FIELD_ROWS
    
    var cells: [[FieldCell]]
    
    var flattenedCells: [FieldCell] {
        return cells.flatMap { $0 }
    }
    
    init() {
        cells = (0..<Global.FIELD_ROWS).map { _ in
            (0..<Global.FIELD_COLUMNS).map { _ in FieldCell() }}
    }
    
    func placeFighters(playerFighters: [Fighter], enemyFighters: [Fighter]) {
        for i in 0..<rows {
            cells[i][0].fighter = playerFighters[i]
            cells[i][columns - 1].fighter = enemyFighters[i]
        }
    }
    
    func cell(id: UUID) -> FieldCell {
        return flattenedCells.first { id == $0.id }!
    }
    
    func cell(withFighter fighter: Fighter) -> UUID? {
        flattenedCells.first { $0.fighter === fighter }?.id
    }
    
    func setFighter(to cellID: UUID, fighter: Fighter?) {
        let (i,j) = self.cellCoords(id: cellID)
        cells[i][j].fighter = fighter
    }
        
    func cellCoords(id: UUID) -> (Int, Int) {
        for i in 0..<rows {
            for j in 0..<columns {
                if cells[i][j].id == id {
                    return (i, j)
                }
            }
        }
        fatalError("cellCoords: id is not on the field")
    }
}
