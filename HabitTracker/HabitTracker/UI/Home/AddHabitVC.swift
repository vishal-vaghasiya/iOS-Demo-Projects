//
//  AddHabitVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import UIKit

class AddHabitVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var lblRepeat: UILabel!
    @IBOutlet weak var lblGoal: UILabel!
    @IBOutlet weak var lblTimeOfDay: UILabel!
    @IBOutlet weak var lblReminders: UILabel!
    @IBOutlet weak var lblChecklist: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var calenderView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - PROPERTY
    var selectedData: HabitCategory?
    
    var selectedRepeat = RepeatModel(type: .daily, value: [1,2,3,4,5,6,7])
    var selectedGoal = Goal()
    var selectedSlots: [TimeSlot] = [TimeSlot(name: "Morning", value: 1),
                                     TimeSlot(name: "Afternoon", value: 2),
                                     TimeSlot(name: "Evening", value: 3)]
    var selectedTimes: [Date] = []
    var checkListItems: [String] = []
    var selectedDate = Date()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIComponents()
    }
    
    // MARK: - UI SETUP
    func setupUIComponents() {
        categoryIcon.image = UIImage(systemName: selectedData?.systemIcon ?? "")
        categoryIcon.tintColor = .label
        txtName.text = selectedData?.name
        configureDatePicker()
        
        updateRepeatLabel()
        updateGoalLabel()
        updateReminderLabel()
        updateChecklistLabel()
        updateStartDateLabel()
    }
    
    func configureDatePicker() {
        calenderView.isHidden = true
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    func updateRepeatLabel() {
        guard let repeatType = selectedRepeat.type, let values = selectedRepeat.value else {
            self.lblRepeat.text = ""
            return
        }
        switch repeatType {
        case .daily:
            // If all 7 days selected
            let allDays = Set([1,2,3,4,5,6,7])
            let selectedDays = Set(values)
            if selectedDays == allDays {
                self.lblRepeat.text = "Everyday"
            } else {
                // Map to short weekday names
                let days = values.sorted().map { shortWeekdayName(for: $0) }
                self.lblRepeat.text = days.joined(separator: ", ")
            }
        case .monthly:
            // Map to ordinals
            let ordinals = values.sorted().map { ordinalString(for: $0) }
            self.lblRepeat.text = "Every month on " + ordinals.joined(separator: ", ")
        case .interval:
            // Assume first value is the interval number
            if let interval = values.first {
                self.lblRepeat.text = "Every \(interval) days"
            } else {
                self.lblRepeat.text = ""
            }
        }
    }

    // Helper: Convert 1...7 to short weekday names (Sun, Mon, ...)
    private func shortWeekdayName(for day: Int) -> String {
        // Assuming 1=Sun, 2=Mon, ..., 7=Sat
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let shortSymbols = formatter.shortWeekdaySymbols ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let index = ((day - 1) % 7)
        if index >= 0 && index < shortSymbols.count {
            return shortSymbols[index]
        }
        return "Day\(day)"
    }

    // Helper: Convert Int to ordinal string (1st, 2nd, 3rd...)
    private func ordinalString(for number: Int) -> String {
        let suffix: String
        let ones = number % 10
        let tens = (number / 10) % 10
        if tens == 1 {
            suffix = "th"
        } else {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(number)\(suffix)"
    }
    
    func updateGoalLabel() {
        let type = selectedGoal.type
        let subType = selectedGoal.subType
        let value = selectedGoal.value

        switch type {
        case .min:
            let unit = value == 1 ? "min" : "mins"
            lblGoal.text = "\(value) \(unit) \(subType.value)"
        case .hours:
            let unit = value == 1 ? "hr" : "hrs"
            lblGoal.text = "\(value) \(unit) \(subType.value)"
        }
    }
    
    func updateTimeOfDayLabel() {
        let vc = StoryboardScene.Home.timeOfDayVC.instantiate()
        let names = selectedSlots.map { $0.name }.joined(separator: ", ")
        if selectedSlots.count == vc.timeSlots.count {
            self.lblTimeOfDay.text = "Any Time"
        } else {
            self.lblTimeOfDay.text = names
        }
    }
    
    func updateReminderLabel() {
        if selectedTimes.isEmpty {
            lblReminders.text = "Off"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timesString = selectedTimes
                .sorted()
                .map { formatter.string(from: $0) }
                .joined(separator: ", ")
            lblReminders.text = timesString
        }
    }
    
    func updateChecklistLabel() {
        if checkListItems.isEmpty {
            lblChecklist.text = "None"
        } else {
            lblChecklist.text = "\(checkListItems.count) Items"
        }
    }
    
    func updateStartDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let selectedDateString = formatter.string(from: self.selectedDate)
         
        let calendar = Calendar.current
        if calendar.isDateInToday(self.selectedDate) {
            lblStartDate.text = "Today"
        } else if calendar.isDateInYesterday(self.selectedDate) {
            lblStartDate.text = "Yesterday"
        } else if calendar.isDateInTomorrow(self.selectedDate) {
            lblStartDate.text = "Tomorrow"
        } else {
            lblStartDate.text = selectedDateString
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let context = CoreDataManager.shared.context
        
        let habit = Habit(context: context)
        habit.id = UUID()
        habit.name = txtName.text ?? ""
        habit.icon = selectedData?.systemIcon ?? ""
        habit.categoryName = selectedData?.name ?? ""
        
        // Repeat
        habit.repeatType = Int32(selectedRepeat.type?.rawValue ?? 0)
        habit.repeatValue = selectedRepeat.value as NSObject?
        
        // Goal
        habit.goalType = Int32(selectedGoal.type.rawValue)
        habit.goalValue = Int32(selectedGoal.value)
        habit.goalSubType = selectedGoal.subType.rawValue
        
        // Time of day
        habit.timeSlots = selectedSlots.map { $0.value } as NSObject
        
        // Reminders
        habit.reminders = selectedTimes as NSObject
        
        // Checklist
        habit.checklist = checkListItems as NSObject
        
        // Start Date
        habit.startDate = selectedDate
        
        CoreDataManager.shared.saveContext()
        
        // Schedule notifications
        NotificationManager.shared.scheduleHabitNotifications(habit: habit)
        
        self.dismiss(animated: true)
    }
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        let vc = StoryboardScene.Home.repeateVC.instantiate()
        vc.selectedRepeat = self.selectedRepeat
        vc.onRepeatSelected = { data in
            self.selectedRepeat = data
            self.updateRepeatLabel()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func goalButtonTapped(_ sender: UIButton) {
        let vc = StoryboardScene.Home.goalVC.instantiate()
        vc.titleString = selectedData?.name ?? ""
        vc.selectedGoal = selectedGoal
        vc.onGoalSelected = { data in
            self.selectedGoal = data
            self.updateGoalLabel()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func timeOfDayButtonTapped(_ sender: UIButton) {
        let vc = StoryboardScene.Home.timeOfDayVC.instantiate()
        vc.selectedSlots = self.selectedSlots
        vc.onTimeSlotsSelected = { selectedSlots in
            self.selectedSlots = selectedSlots
            self.updateTimeOfDayLabel()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func reminderButtonTapped(_ sender: UIButton) {
        let vc = StoryboardScene.Home.remindersVC.instantiate()
        vc.selectedTimes = self.selectedTimes
        vc.onTimesSelected = { times in
            self.selectedTimes = times
            self.updateReminderLabel()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func checklistButtonTapped(_ sender: UIButton) {
        let vc = StoryboardScene.Home.checkListVC.instantiate()
        vc.checkListItems = self.checkListItems
        vc.onChecklistUpdated = { updatedList in
            self.checkListItems = updatedList
            self.updateChecklistLabel()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func startDateButtonTapped(_ sender: UIButton) {
        let shouldShow = calenderView.isHidden
        if shouldShow {
            calenderView.alpha = 0
            calenderView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.calenderView.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.calenderView.alpha = 0
            }, completion: { _ in
                self.calenderView.isHidden = true
            })
        }
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    @objc func dateChanged(_ sender: UIDatePicker) {
        self.selectedDate = sender.date
        self.updateStartDateLabel()
    }
    
}
