//
//  InfinitePickerView.swift
//  BattleField
//
//  Created by Sergey Kozlov on 28.02.2025.
//

import UIKit

protocol DialViewDelegate: AnyObject {
    func dialView(_ dialView: DialView, didRollFinished: Void)
}

class DialView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: DialViewDelegate?
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    

    private let baseNumbers = [1, 2, 3, 4, 5, 6]
    private let numberOfCycles = 100 // Количество циклов для иллюзии бесконечности
    private lazy var numbers: [Int] = {
        return Array(repeating: baseNumbers, count: numberOfCycles).flatMap { $0 }
    }()
    
    
    // Состояние для физической прокрутки
    private var displayLink: CADisplayLink?
    private var velocity: CGFloat = 0.0
    private var targetRow: Int = 0
    private var rollTime: Double = 2.0
    private var lastTimeSpan: TimeInterval?
    private var rollProgress = 0.0
    private var animationCurve: AnimationCurveFunction!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Устанавливаем начальное значение в середине для симметрии
        let initialRow = numbers.count / 2
        pickerView.selectRow(initialRow, inComponent: 0, animated: false)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Один компонент (колонка)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count // Очень большое число строк для иллюзии бесконечности
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(numbers[row % baseNumbers.count]) // Возвращаем число по модулю, чтобы повторять 1–6
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    

    func roll(to row: Int, initialVelocity: CGFloat = 1) {
        
        lastTimeSpan = nil
        rollProgress = 0.0
        self.targetRow = baseNumbers.count * 10 + row - 1
        pickerView.selectRow(0, inComponent: 0, animated: false)
        velocity = initialVelocity
        
        stopSpinAnimation()
        
        animationCurve = SqrtFunction(asInterpolationWith: CGPoint(x: rollTime, y: Double(targetRow)))
        displayLink = CADisplayLink(target: self, selector: #selector(updateSpin))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // Остановка анимации физической прокрутки
    func stopSpinAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // Метод для обновления анимации физической прокрутки
     @objc func updateSpin(_ displayLink: CADisplayLink) {

        guard let lastTimeSpan else {
            lastTimeSpan = displayLink.timestamp
            return
        }
        
        let currentRow = pickerView.selectedRow(inComponent: 0)
        if (currentRow == targetRow) {
            stopSpinAnimation()
            delegate?.dialView(self, didRollFinished: Void())
        }
        
        
        let deltaTime = displayLink.timestamp - lastTimeSpan
        let rollProgress = animationCurve.y(x: Float(deltaTime))

        let resultRow = (Int(rollProgress) < targetRow) ? Int(rollProgress) : targetRow
        pickerView.selectRow(resultRow, inComponent: 0, animated: false)

    }
    
    deinit {
        stopSpinAnimation()
    }
}






