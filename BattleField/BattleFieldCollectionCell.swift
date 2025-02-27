//
//  FieldCollectionCell.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import UIKit

class BattleFieldCollectionCell: UICollectionViewCell {
    
    func setFighter(fighter: Fighter?) {
        imageView.image = fighter != nil ? UIImage(systemName: fighter!.imageName) : nil
        imageView.tintColor = fighter?.imageColor
    }
    

            

    
    lazy var imageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
