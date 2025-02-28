//
//  InfinitePickerView.swift
//  BattleField
//
//  Created by Sergey Kozlov on 28.02.2025.
//

import UIKit

class DialViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction() { _ in
            self.spinPickerWheel(to: 6*6)
        }, for: .touchUpInside)
        return button
    }()
    
    // Базовые числа (1–6)
    private let baseNumbers = [1, 2, 3, 4, 5, 6]
    private let numberOfCycles = 100 // Количество циклов для иллюзии бесконечности
    private lazy var numbers: [Int] = {
        return Array(repeating: baseNumbers, count: numberOfCycles).flatMap { $0 }
    }()
    
    
    // Состояние для физической прокрутки
    private var displayLink: CADisplayLink?
    private var velocity: CGFloat = 0.0
    private var isDecelerating: Bool = false
    private var deceleration: CGFloat = 0.95
    private var targetRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickerView()

        view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
            
    }
    
    private func setupPickerView() {
        view.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalToConstant: 200),
            pickerView.heightAnchor.constraint(equalToConstant: 150)
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
    
    // Программная прокрутка с имитацией физики (замедление)
    func spinPickerWheel(to targetRow: Int, initialVelocity: CGFloat = 1, deceleration: CGFloat = 0.95) {
        self.targetRow = targetRow
        pickerView.selectRow(0, inComponent: 0, animated: false)
        velocity = initialVelocity
        isDecelerating = false
        self.deceleration = deceleration
        
        stopSpinAnimation()
        
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

        let currentRow = pickerView.selectedRow(inComponent: 0)
        if currentRow < targetRow {
            if isDecelerating {
                velocity *= deceleration
                if velocity < 0.1 {
                    velocity = 0
                    stopSpinAnimation()
                    return
                }
            }
            
            let rowsRemains = targetRow - currentRow
            let rowsToMove = (Int(velocity) < rowsRemains) ? Int(velocity) : rowsRemains
            pickerView.selectRow(currentRow + rowsToMove, inComponent: 0, animated: false)
        } else {
            stopSpinAnimation()
        }
    }
    
//    // Остановка на конкретном числе
//    func stopSpinAnimation(at number: Int) {
//        stopSpinAnimation()
//        let targetRow = currentRow + (number - (numbers[currentRow % baseNumbers.count]))
//        pickerView.selectRow(targetRow, inComponent: 0, animated: true)
//    }
    
    deinit {
        stopSpinAnimation()
    }
}
