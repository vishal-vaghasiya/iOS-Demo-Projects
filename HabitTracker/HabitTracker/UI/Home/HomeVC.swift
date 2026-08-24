//
//  HomeVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 18/08/25.
//

import UIKit
struct HabitCategory {
    let name: String
    let systemIcon: String
    let defaulGoal: Goal?
}

class HomeVC: UIViewController {
    
    // MARK: - OUTLET
    @IBOutlet weak var habitTV: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    // MARK: - PROPERTY
    var habits: [Habit] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoader()
        habits = CoreDataManager.shared.fetchHabits()
        habitTV.reloadData()
        hideLoader()
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        self.habitTV.register(UINib(nibName: HabitListTVCell.identifier, bundle: nil), forCellReuseIdentifier: HabitListTVCell.identifier)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func plusButtonClick(_ sender: UIButton) {
        let sheet = UIAlertController(title: "Choose Category Type", message: nil, preferredStyle: .actionSheet)
        
        for category in defaultCategory {
            let action = UIAlertAction(title: category.name, style: .default) { _ in
                let vc = StoryboardScene.Home.addHabitVC.instantiate()
                vc.selectedData = category
                vc.isModalInPresentation = true
                let nv = UINavigationController(rootViewController: vc)
                nv.isNavigationBarHidden = true
                self.present(nv, animated: true)
            }
            action.setValue(UIImage(systemName: category.systemIcon), forKey: "image")
            sheet.addAction(action)
        }
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(sheet, animated: true, completion: nil)
        //        let mainSheet = UIAlertController(title: "Choose Category Type", message: nil, preferredStyle: .actionSheet)
        //
        //        let suggestedAction = UIAlertAction(title: "Suggested Categories", style: .default) { _ in
        //            self.showCategorySheet(sender: sender, categories: suggestedCategories, title: "Suggested")
        //        }
        //        let healthAction = UIAlertAction(title: "Health Categories", style: .default) { _ in
        //            self.showCategorySheet(sender: sender, categories: healthCategories, title: "Health")
        //        }
        //
        //        mainSheet.addAction(suggestedAction)
        //        mainSheet.addAction(healthAction)
        //        mainSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //
        //        if let popover = mainSheet.popoverPresentationController {
        //            popover.sourceView = sender
        //            popover.sourceRect = sender.bounds
        //        }
        //
        //        present(mainSheet, animated: true, completion: nil)
    }
    
    // MARK: - OTHER
    private func showCategorySheet(sender: UIButton, categories: [HabitCategory], title: String) {
        let sheet = UIAlertController(title: "\(title) Categories", message: nil, preferredStyle: .actionSheet)
        
        for category in categories {
            let action = UIAlertAction(title: category.name, style: .default) { _ in
                let vc = StoryboardScene.Home.addHabitVC.instantiate()
                vc.selectedData = category
                vc.isModalInPresentation = true  // Disable swipe-to-dismiss
                let nv = UINavigationController(rootViewController: vc)
                nv.isNavigationBarHidden = true
                self.present(nv, animated: true)
            }
            action.setValue(UIImage(systemName: category.systemIcon), forKey: "image")
            sheet.addAction(action)
        }
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(sheet, animated: true, completion: nil)
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE
    
}
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitListTVCell.identifier, for: indexPath) as! HabitListTVCell
        let habit = habits[indexPath.row]
        
        // Icon
        if let iconName = habit.icon {
            cell.ivCategoryLogo.image = UIImage(systemName: iconName)
        } else {
            cell.ivCategoryLogo.image = UIImage(systemName: "circle")
        }
        
        // Title
        cell.lblTitle.text = habit.name ?? "Untitled"
        
        // Goal progress (example: "Completed 2 / 5 per Day")
        let goalValue = habit.goalValue
        let subType = habit.goalSubType ?? ""
        let unit = GoalType(rawValue: Int(habit.goalType)) == .hours ? "hr" : "min"
        let completed = habit.completedGoal
        
        if habit.isCompleted {
            cell.lblGoal.text = "Completed!"
        } else {
            cell.lblGoal.text = "\(completed) / \(goalValue) \(unit) \(subType)"
        }
        
        cell.timerButton.tag = indexPath.row
        cell.timerButton.addTarget(self, action: #selector(onStartTimerButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func onStartTimerButtonTapped(_ sender: UIButton) {
        let habit = habits[sender.tag]
        let vc = StoryboardScene.Home.startTimerVC.instantiate()
        vc.habit = habit
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habit = habits[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "Delete Habit",
                                          message: "Are you sure you want to delete this habit?",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let habitToDelete = self.habits[indexPath.row]
                
                // Remove from Core Data
                CoreDataManager.shared.context.delete(habitToDelete)
                CoreDataManager.shared.saveContext()
                
                // Remove from local array & tableView
                self.habits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Cancel any scheduled notifications for this habit
                if let habitId = habitToDelete.id?.uuidString {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitId])
                }
                
                completionHandler(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Leading Swipe (Mark as Completed)
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if habits[indexPath.row].isCompleted {
            return nil
        }
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let habit = self.habits[indexPath.row]
            
            // Mark as completed
            CoreDataManager.shared.markHabitAsCompleted(habit)
            
            // Reload just that row
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        completeAction.backgroundColor = .systemGreen
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
