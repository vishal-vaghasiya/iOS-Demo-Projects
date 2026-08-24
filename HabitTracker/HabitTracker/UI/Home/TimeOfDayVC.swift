//
//  TimeOfDayVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 19/08/25.
//

import UIKit

struct TimeSlot {
    let name: String
    let value: Int
}

class TimeOfDayVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var timeOfDayCV: UICollectionView!
    
    // MARK: - PROPERTY
    let timeSlots: [TimeSlot] = [
        TimeSlot(name: "Morning", value: 1),
        TimeSlot(name: "Afternoon", value: 2),
        TimeSlot(name: "Evening", value: 3)
    ]
    
    var selectedSlots: [TimeSlot] = []
    
    var onTimeSlotsSelected: (([TimeSlot]) -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        timeOfDayCV.register(UINib(nibName: InfoCVCell.identifier, bundle: nil),
                             forCellWithReuseIdentifier: InfoCVCell.identifier)
        timeOfDayCV.register(UINib(nibName: WeekCVCell.identifier, bundle: nil),
                             forCellWithReuseIdentifier: WeekCVCell.identifier)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        onTimeSlotsSelected?(selectedSlots)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension TimeOfDayVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeSlots.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == timeSlots.count {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: InfoCVCell.identifier,
                for: indexPath
            ) as! InfoCVCell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: WeekCVCell.identifier,
                for: indexPath
            ) as! WeekCVCell
            let slot = timeSlots[indexPath.row]
            cell.lblName.text = slot.name
            cell.checkmark.isHidden = !selectedSlots.contains { $0.value == slot.value }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == timeSlots.count - 1 {
            return CGSize(width: collectionView.frame.width, height: 50)
        } else {
            return CGSize(width: collectionView.frame.width, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == timeSlots.count { return } // ignore Info
        
        let slot = timeSlots[indexPath.row]
        if let index = selectedSlots.firstIndex(where: { $0.value == slot.value }) {
            selectedSlots.remove(at: index)
        } else {
            selectedSlots.append(slot)
        }
        collectionView.reloadData()
    }
}

