//
//  FighterMovementAnimator.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import UIKit

class FighterMovementAnimator
{
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    
    init(collectionView: UICollectionView, diffableDataSource: UICollectionViewDiffableDataSource<Int, UUID>) {
        self.collectionView = collectionView
        self.dataSource = diffableDataSource
    }
    
    func animateMovement(fighter: Fighter, to destCellId: UUID) {
        let field = Field.shared
        var startCellId = field.cell(withFighter: fighter)!
        var startCollectionCell = collectionView.cellForItem(at: dataSource.indexPath(for: startCellId)!)
    }
}
