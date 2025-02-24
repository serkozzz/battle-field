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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.dragInteractionEnabled = true // Включить drag
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        // Do any additional setup after loading the view.
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath,
            cellID in
            guard let self = self else { return nil }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
            let cellModel = Field.shared.cell(id: cellID)
            
            var backgroundConf = cell.defaultBackgroundConfiguration()
            
            if (dragDestinationID == cellID) {
                backgroundConf.backgroundColor = .blue
            }
            else {
                switch game.cellState(id: cellID) {
                case.normal:
                    backgroundConf.backgroundColor = .systemGray5
                case .accesable:
                    backgroundConf.backgroundColor = .init(red: 0, green: 1, blue: 0, alpha: 0.4)
                case .forbidden:
                    backgroundConf.backgroundColor = .red
                }
            }
            cell.backgroundConfiguration = backgroundConf
            
            var conf = UIListContentConfiguration.cell()
            conf.image = cellModel.fighter != nil ? UIImage(systemName: cellModel.fighter!.imageName) : nil
            
            cell.contentConfiguration = conf
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
        let itemProvider = NSItemProvider(object: NSString())
        let dragItem = UIDragItem(itemProvider: itemProvider)
        var id = dataSource.itemIdentifier(for: indexPath)!
        dragItem.localObject = dataSource.itemIdentifier(for: indexPath)
        game.selectedCell = Field.shared.cell(id: id)
        
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
        game.selectedCell = nil
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
