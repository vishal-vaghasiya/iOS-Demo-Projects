//
//  GoalVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 19/08/25.
//

import UIKit

enum GoalType: Int {
    case min = 1
    case hours = 2
}

enum GoalSubType: String {
    case perDay
    case perWeek
    case perMonth

    var value: String {
        switch self {
        case .perDay: return "per day"
        case .perWeek: return "per week"
        case .perMonth: return "per month"
        }
    }
}

class Goal {
    var type: GoalType
    var value: Int
    var subType: GoalSubType
    
    init(type: GoalType = .min, value: Int = 30, subType: GoalSubType = .perDay) {
        self.type = type
        self.value = value
        self.subType = subType
    }
}

class GoalVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - PROPERTY
    let minComponent = Array(1...1200)
    let unitComponent = ["min", "hours"]
    let subTypeComponent = ["per Day", "per Week", "per Month"]
    
    var titleString = String()
    var selectedGoal = Goal()
    var onGoalSelected: ((Goal) -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleString
        setupPickerView()
    }
    
    // MARK: - UI SETUP
    func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueIndex = selectedGoal.value - 1
        let unitIndex = (selectedGoal.type == .hours) ? 1 : 0
        let subTypeIndex = subTypeComponent.firstIndex(of: selectedGoal.subType.rawValue) ?? 0

        pickerView.selectRow(valueIndex, inComponent: 0, animated: false)
        pickerView.selectRow(unitIndex, inComponent: 1, animated: false)
        pickerView.selectRow(subTypeIndex, inComponent: 2, animated: false)
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        onGoalSelected?(selectedGoal)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
extension GoalVC: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // Value, Unit, SubType
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return minComponent.count
        case 1: return unitComponent.count
        case 2: return subTypeComponent.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(minComponent[row])"
        case 1: return unitComponent[row]
        case 2: return subTypeComponent[row]
        default: return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let ratios: [CGFloat] = [0.3, 0.25, 0.45] // widths for value, unit, and subtype
        guard component < ratios.count else { return 100 }
        return pickerView.frame.width * ratios[component]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = minComponent[pickerView.selectedRow(inComponent: 0)]
        let selectedUnit = unitComponent[pickerView.selectedRow(inComponent: 1)]
        let selectedSubType = subTypeComponent[pickerView.selectedRow(inComponent: 2)]

        selectedGoal.value = selectedValue
        selectedGoal.type = selectedUnit == "min" ? .min : .hours
        selectedGoal.subType = GoalSubType(rawValue: selectedSubType) ?? .perDay
    }
    
}
