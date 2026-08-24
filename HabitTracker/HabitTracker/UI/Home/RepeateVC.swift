//
//  RepeateVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 19/08/25.
//

import UIKit

enum RepeatType: Int {
    case daily = 0
    case monthly = 1
    case interval = 2
}

class RepeatModel {
    var type: RepeatType?
    var value: [Int]?
    
    init(type: RepeatType, value: [Int]) {
        self.type = type
        self.value = value
    }
}

class RepeateVC: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var dailyIntervalCV: UICollectionView!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    // MARK: - PROPERTIES
    var selectedType: RepeatType? = RepeatType(rawValue: 0)
    
    var selectedDayView = RepeatModel(type: .daily, value: [1,2,3,4,5,6,7])
    var selectedMonthlyView = RepeatModel(type: .monthly, value: [])
    var selectedIntervalView = RepeatModel(type: .interval, value: [])
    
    var selectedRepeat = RepeatModel(type: .daily, value: [1,2,3,4,5,6,7])
    var onRepeatSelected: ((RepeatModel) -> Void)?
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    private func setupUI() {
        dailyIntervalCV.register(UINib(nibName: WeekCVCell.identifier, bundle: nil),
                                 forCellWithReuseIdentifier: WeekCVCell.identifier)
        dailyIntervalCV.register(UINib(nibName: DayViewCVCell.identifier, bundle: nil),
                                 forCellWithReuseIdentifier: DayViewCVCell.identifier)
        
        selectedType = selectedRepeat.type
        typeSegment.selectedSegmentIndex = selectedType?.rawValue ?? 0
        
        switch selectedRepeat.type {
        case .daily:
            selectedDayView = selectedRepeat
        case .monthly:
            selectedMonthlyView = selectedRepeat
        case .interval:
            selectedIntervalView = selectedRepeat
        case .none:
            break
        }
    }
    
    // MARK: - BUTTON ACTIONS
    @IBAction func backButtonClick(_ sender: UIButton) {
        onRepeatSelected?(getSelectedTypeValue())
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        selectedType = RepeatType(rawValue: sender.selectedSegmentIndex)
        dailyIntervalCV.reloadData()
    }
    
    // MARK: - HELPERS
    private func getSelectedTypeValue() -> RepeatModel {
        switch selectedType {
        case .daily:
            return selectedDayView
        case .monthly:
            return selectedMonthlyView
        case .interval:
            return selectedIntervalView
        case .none:
            return selectedDayView
        }
    }
}

// MARK: - COLLECTION VIEW DELEGATE & DATASOURCE
extension RepeateVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedType {
        case .daily:
            return AppData.shared.arrOfWeekDay.count
        case .monthly:
            return AppData.shared.arrOfDay.count
        case .interval:
            return AppData.shared.arrOfInterval.count
        case .none:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch selectedType {
        case .daily:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekCVCell.identifier, for: indexPath) as! WeekCVCell
            let data = AppData.shared.arrOfWeekDay[indexPath.row]
            cell.lblName.text = data.name
            cell.checkmark.isHidden = !(selectedDayView.value?.contains(data.value) ?? false)
            return cell
            
        case .monthly:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayViewCVCell.identifier, for: indexPath) as! DayViewCVCell
            let data = AppData.shared.arrOfDay[indexPath.row]
            cell.lblDate.text = data.toString()
            let isSelected = selectedMonthlyView.value?.contains(data) ?? false
            cell.backgroundColor = isSelected ? .systemPurple : .white
            return cell
            
        case .interval:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekCVCell.identifier, for: indexPath) as! WeekCVCell
            let data = AppData.shared.arrOfInterval[indexPath.row]
            cell.lblName.text = data.name
            cell.checkmark.isHidden = !(selectedIntervalView.value?.contains(data.value) ?? false)
            return cell
            
        case .none:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedType == .daily || selectedType == .interval {
            return CGSize(width: collectionView.frame.width, height: 60)
        } else {
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 44, height: 44)
            }
            let spacing = layout.minimumInteritemSpacing
            let sectionInsets = layout.sectionInset.left + layout.sectionInset.right
            let totalSpacing = spacing * 6 + sectionInsets
            let width = collectionView.frame.width - totalSpacing
            let size = floor(width / 7)
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectedType {
        case .daily:
            let data = AppData.shared.arrOfWeekDay[indexPath.row].value
            if let index = selectedDayView.value?.firstIndex(of: data) {
                selectedDayView.value?.remove(at: index)
            } else {
                selectedDayView.value?.append(data)
            }
            
        case .monthly:
            let data = AppData.shared.arrOfDay[indexPath.row]
            if let index = selectedMonthlyView.value?.firstIndex(of: data) {
                selectedMonthlyView.value?.remove(at: index)
            } else {
                selectedMonthlyView.value?.append(data)
            }
            
        case .interval:
            let data = AppData.shared.arrOfInterval[indexPath.row].value
            if let index = selectedIntervalView.value?.firstIndex(of: data) {
                selectedIntervalView.value?.remove(at: index)
            } else {
                selectedIntervalView.value?.append(data)
            }
            
        case .none:
            break
        }
        collectionView.reloadData()
    }
}
