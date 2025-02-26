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
    
    func animateMovement(fighter: Fighter, to destCellId: UUID, completed: (() -> Void)? = nil)
    {
        let field = Field.shared
        let startCellId = field.cell(withFighter: fighter)!
        let startCollectionCell = collectionView.cellForItem(at: dataSource.indexPath(for: startCellId)!) as! BattleFieldCollectionCell
        let destCollectionCell = collectionView.cellForItem(at: dataSource.indexPath(for: destCellId)!) as! BattleFieldCollectionCell
        let startFrame = startCollectionCell.convert(startCollectionCell.imageView.frame, to: collectionView)
        let destFrame = destCollectionCell.convert(destCollectionCell.imageView.frame, to: collectionView)

        let imageViewToMove = startCollectionCell.imageView.snapshotView(afterScreenUpdates: true)!
        imageViewToMove.removeFromSuperview()
        collectionView.addSubview(imageViewToMove)
        imageViewToMove.frame = startFrame
        startCollectionCell.image = nil
        
        UIView.animate(withDuration: 1.0, animations: {
            imageViewToMove.frame = destFrame
    
        }, completion: { _ in
            imageViewToMove.removeFromSuperview()
            completed?()
        });
        

        
    }
}
