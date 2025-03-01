//
//  FieldCollectionCell.swift
//  BattleField
//
//  Created by Sergey Kozlov on 25.02.2025.
//

import UIKit

class BattleFieldCollectionCell: UICollectionViewCell {
    static let reuseID = "BattleFieldCollectionCell"
    
    func setFighter(fighter: Fighter?) {
        imageView.image = fighter != nil ? UIImage(systemName: fighter!.imageName) : nil
        imageView.tintColor = fighter?.imageColor
    }
    
    func blinkBorder() {
        
        let color = layer.borderColor
        layer.borderColor = UIColor.clear.cgColor // Начальный цвет — прозрачный
        
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = UIColor.clear.cgColor
        animation.toValue = color
        animation.duration = 0.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // Плавное начало и конец
        
        layer.add(animation, forKey: "borderBlink")
    }
    
    func stopBlinkBorder() {
        layer.removeAnimation(forKey: "borderBlink") // Удаляем анимацию по ключу
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
