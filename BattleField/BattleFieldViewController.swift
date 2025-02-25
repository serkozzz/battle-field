//
//  ViewController.swift
//  BattleField
//
//  Created by Sergey Kozlov on 22.02.2025.
//

import UIKit

private var reuseIdentifier = "Cell"

class BattleFieldViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    var dragDestinationID: UUID?
    
    var game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(BattleFieldCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.dragInteractionEnabled = true // Включить drag
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        // Do any additional setup after loading the view.
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath,
            cellID in
            guard let self = self else { return nil }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BattleFieldCollectionCell
            let cellModel = Field.shared.cell(id: cellID)
            
            if (dragDestinationID == cellID) {
                //cell.backgroundColor = .blue
                cell.layer.borderWidth = 2
                cell.layer.borderColor = UIColor.black.cgColor
            }
            else {
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
        
    
            cell.image = cellModel.fighter != nil ? UIImage(systemName: cellModel.fighter!.imageName) : nil
            return cell
        }
        applySnapshot()
    }
    
    func applySnapshot(){
        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(Field.shared.flattenedCells.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([0])
        dataSource.apply(snapshot)
    }
}

extension BattleFieldViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let id = dataSource.itemIdentifier(for: indexPath)!
        
        if !game.canStartMovement(cellID: id) {
            return []
        }
        
        let itemProvider = NSItemProvider(object: NSString())
        let dragItem = UIDragItem(itemProvider: itemProvider)

        
        dragItem.localObject = id
        game.startMovement(cellID: id)
        
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
        
        if let dstIdxPath = destinationIndexPath {
        
            let srcItemID = session.localDragSession!.items.first!.localObject as! UUID
            let dstItemID = dataSource.itemIdentifier(for: dstIdxPath)!
            
            if dstItemID != srcItemID && dstItemID != dragDestinationID  {
                var itemsToReload: [UUID] = []
                if let prevDst = dragDestinationID {
                    itemsToReload.append(prevDst)
                }
                dragDestinationID = dstItemID
                itemsToReload.append(dstItemID)
                
                var snapshot = dataSource.snapshot()
                snapshot.reloadItems(itemsToReload)
                dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
        return UICollectionViewDropProposal(operation: .move)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        game.moveTo(cellId: dragDestinationID!)
        dragDestinationID = nil
        reloadSnapshot()
        return
    }
    
    
}



extension BattleFieldViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self else { return nil }
            
            let itemWidth = 1 / CGFloat( Field.shared.columns)
            let itemHeight = 1 / CGFloat(Field.shared.rows)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemWidth), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(itemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            return NSCollectionLayoutSection(group: group)
            
        }
    }
}
