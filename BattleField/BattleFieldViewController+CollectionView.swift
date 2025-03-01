//
//  BattleFieldViewController+Layout.swift
//  BattleField
//
//  Created by Sergey Kozlov on 01.03.2025.
//

import UIKit


extension BattleFieldViewController {
    
    
    func createDataSource() -> UICollectionViewDiffableDataSource<Int, UUID> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath,
            cellID in
            guard let self = self else { return nil }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BattleFieldCollectionCell.reuseID, for: indexPath) as! BattleFieldCollectionCell
            let cellModel = field.cell(id: cellID)
            
            if (game.getFighterMovementDestination() == cellID) {
                cell.layer.borderWidth = 2
                cell.layer.borderColor =  UIColor.black.cgColor
                
                if (cellModel.fighter != nil) {
                    cell.layer.borderColor =  UIColor.red.cgColor
                    cell.blinkBorder()
                }
            }
            else {
                cell.stopBlinkBorder()
                cell.layer.borderWidth = 0
            }
            switch game.cellState(id: cellID) {
            case.normal:
                cell.backgroundColor = .systemGray6
            case .accesable:
                cell.backgroundColor = .init(red: 0, green: 1, blue: 0, alpha: 0.2)
            case .forbidden:
                cell.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 0.6)
            }
        
            cell.setFighter(fighter: cellModel.fighter)
            return cell
        }
    }
    
    func applySnapshot(){
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(field.flattenedCells.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadSnapshot(animating: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([0])
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
    
    func reloadSnapshot(items: [UUID], animating: Bool = true, completion: (() -> Void)? = nil) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items)
        dataSource.apply(snapshot, animatingDifferences: animating, completion: completion)
    }
    
    
}



extension BattleFieldViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self else { return nil }
            
            let itemWidth = 1 / CGFloat(field.columns)
            let itemHeight = 1 / CGFloat(field.rows)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemWidth), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            return NSCollectionLayoutSection(group: group)
            
        }
    }
}
