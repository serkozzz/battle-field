//
//  Untitled.swift
//  BattleField
//
//  Created by Sergey Kozlov on 01.03.2025.
//

import UIKit

extension BattleFieldViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let id = dataSource.itemIdentifier(for: indexPath)!
        
        if game.turn != .player || !game.canStartFighterMovement(cellID: id) {
            return []
        }
        game.startFighterMovement(cellID: id)
        
        let itemProvider = NSItemProvider(object: NSString())
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = id
        
        let cell = collectionView.cellForItem(at: indexPath) as! BattleFieldCollectionCell
        let previewCell = cell.snapshotView(afterScreenUpdates: false)!
        //previewCell.backgroundColor = .clear
        
        dragItem.previewProvider = {
            
            let previewParams = UIDragPreviewParameters()
            previewParams.backgroundColor = .clear // Полностью прозрачный фон
            previewParams.visiblePath = UIBezierPath(roundedRect: previewCell.frame, cornerRadius: 10)
            
            let preview = UIDragPreview(view: previewCell, parameters: previewParams)
            return preview
        }
        
        reloadSnapshot()
        return [dragItem]
    }
    

    
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        
        guard let dstIdxPath = destinationIndexPath else { return UICollectionViewDropProposal(operation: .forbidden) }
        
        let dstItemID = dataSource.itemIdentifier(for: dstIdxPath)!
        
        var resultDropProposal = UICollectionViewDropProposal(operation: .move)
        let previousDst = game.getFighterMovementDestination()
        
        if game.canMoveFighter(to: dstItemID) {
            game.setFighterMovementDestinaiton(cellID: dstItemID)
        }
        else {
            game.setFighterMovementDestinaiton(cellID: nil)
            resultDropProposal = UICollectionViewDropProposal(operation: .forbidden)
        }
            
        if previousDst != game.getFighterMovementDestination() {
            reloadSnapshot(items: [previousDst, dstItemID].compactMap{$0}, animating: false)
        }
        return resultDropProposal
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: any UIDragSession) {
        //It needs to reset cell colors to normal if you drop to forbidden area(red cell or beetween cells)
        cancelMovement()
    }

    
    func cancelMovement() {
        guard game.isFighterMovementActive() else { return }
        game.resetFighterMovement()
        reloadSnapshot(animating: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        //drop is called only for valid destination.
        //the next check may be unneccessary, but apply gives us coordinator.destinationIndexPath as optional.
        guard let dropDestIndex = coordinator.destinationIndexPath,
              let dropDest = dataSource.itemIdentifier(for: dropDestIndex),
              let dragItem = coordinator.items.first?.dragItem
        else {
            cancelMovement()
            return
        }
    
        
        dropAnimator = coordinator.drop(dragItem, toItemAt: dropDestIndex)
        game.setFighterMovementDestinaiton(cellID: dropDest)
        game.moveFighterToDestination()
        return
    }
}
