//
//  RemindersVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 19/08/25.
//

import UIKit

class RemindersVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var timeSlotCV: UICollectionView!
    @IBOutlet weak var conHeight: NSLayoutConstraint!
    
    // MARK: - PROPERTY
    var selectedTimes: [Date] = []
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var onTimesSelected: (([Date]) -> Void)?
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        timeSlotCV.register( UINib(nibName: TimeSlotCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: TimeSlotCVCell.identifier)
        timeSlotCV.register( UINib(nibName: AddTimeSlotCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: AddTimeSlotCVCell.identifier)
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        onTimesSelected?(selectedTimes)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension RemindersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedTimes.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == selectedTimes.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddTimeSlotCVCell.identifier, for: indexPath) as! AddTimeSlotCVCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeSlotCVCell.identifier, for: indexPath) as! TimeSlotCVCell
            let time = selectedTimes[indexPath.item]
            cell.lblTime.text = dateFormatter.string(from: time)
            cell.btnClear.tag = indexPath.item
            cell.btnClear.addTarget(self, action: #selector(clearTimeslot(_ :)), for: .touchUpInside)
            return cell
        }
    }
    
   @objc func clearTimeslot(_ sender: UIButton) {
       selectedTimes.remove(at: sender.tag)
       timeSlotCV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.conHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedTimes.count {
            // Add button tapped - show UIDatePicker to add new time
            let alert = UIAlertController(title: "Add Time", message: nil, preferredStyle: .alert)
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            
            let contentViewController = UIViewController()
            contentViewController.view.addSubview(datePicker)
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: contentViewController.view.topAnchor),
                datePicker.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: contentViewController.view.trailingAnchor),
                datePicker.bottomAnchor.constraint(equalTo: contentViewController.view.bottomAnchor),
                datePicker.heightAnchor.constraint(equalToConstant: 160)
            ])
            contentViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 160)
            alert.setValue(contentViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedTimes.append(datePicker.date)
                self.timeSlotCV.reloadData()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            // Time cell tapped - allow editing or removing
            let time = selectedTimes[indexPath.item]
            let alert = UIAlertController(title: "Edit Time", message: nil, preferredStyle: .alert)
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            datePicker.date = time
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            
            let contentViewController = UIViewController()
            contentViewController.view.addSubview(datePicker)
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: contentViewController.view.topAnchor),
                datePicker.leadingAnchor.constraint(equalTo: contentViewController.view.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: contentViewController.view.trailingAnchor),
                datePicker.bottomAnchor.constraint(equalTo: contentViewController.view.bottomAnchor),
                datePicker.heightAnchor.constraint(equalToConstant: 160)
            ])
            contentViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 160)
            alert.setValue(contentViewController, forKey: "contentViewController")
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedTimes.remove(at: indexPath.item)
                self.timeSlotCV.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedTimes[indexPath.item] = datePicker.date
                self.timeSlotCV.reloadData()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}
