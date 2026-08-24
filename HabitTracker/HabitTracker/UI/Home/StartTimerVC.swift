//
//  StartTimerVC.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 20/08/25.
//

import UIKit

enum EventType {
    case start
    case pause
    case resume
    case stop
}

class StartTimerVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var btnStartPauseStop: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblGoalCompted: UILabel!
    
    // MARK: - PROPERTY
    var eventType = EventType.start
    var remainingSeconds : Int = 0
    var totalSeconds : Int = 0
    var habit: Habit?
    
    var timer: Timer?
    var isRunning = false
    var completedMinutes = Int()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtonUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lblTimer.layer.cornerRadius = lblTimer.frame.height / 2
        lblTimer.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
        eventType = .stop
        setupButtonUI()
    }
    
    // MARK: - UI SETUP
    func setupUI() {
        let completedGoal = habit?.completedGoal ?? 0
        var totalGoal = habit?.goalValue ?? 0
        if GoalType(rawValue: Int(habit?.goalType ?? 0)) == .hours {
            totalGoal = (habit?.goalValue ?? 0) * 60
        }
        totalSeconds = (Int((totalGoal) - (completedGoal)) * 60)
        remainingSeconds = totalSeconds
        self.lblTimer.text = remainingSeconds.toTimeString
    }
    
    func setupButtonUI() {
        switch eventType {
        case .start:
            self.btnStartPauseStop.setTitle("Start", for: .normal)
            btnStop.isHidden = true   // Hide Stop when timer not started
            lblGoalCompted.isHidden = true
        case .pause:
            self.btnStartPauseStop.setTitle("Pause", for: .normal)
            btnStop.isHidden = false  // Show Stop when timer is running
            lblGoalCompted.isHidden = true
        case .resume:
            self.btnStartPauseStop.setTitle("Resume", for: .normal)
            btnStop.isHidden = false  // Show Stop when paused (user may cancel)
            lblGoalCompted.isHidden = true
        case .stop:
            self.btnStartPauseStop.setTitle( "Save", for: .normal)
            btnStop.isHidden = true   // Hide Stop when saving/completed
            let completedSeconds = totalSeconds - remainingSeconds
            
            if completedSeconds < 30 {
                completedMinutes = 0
            } else {
                completedMinutes = Int(round(Double(completedSeconds) / 60.0))
            }

            self.lblGoalCompted.text = "Completed: \(completedMinutes) min"
            lblGoalCompted.isHidden = false
        }
    }
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func backButtonClick(_ sender: UIButton) {
        stopTimer()
        eventType = .stop
        setupButtonUI()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startStopButtonClick(_ sender: UIButton) {
        switch eventType {
        case .start:
            // Initialize remainingSeconds from remainingMinutes, start timer, set eventType, update button UI
            startTimer()
            eventType = .pause
            setupButtonUI()
        case .pause:
            // Pause timer, set eventType, update button UI
            pauseTimer()
            eventType = .resume
            setupButtonUI()
        case .resume:
            // Resume timer, set eventType, update button UI
            startTimer()
            eventType = .pause
            setupButtonUI()
        case .stop:
            // Save timer and dismiss view controller
            if let habit = habit {
                CoreDataManager.shared.updateHabitGoal(habit, completedMinutes: completedMinutes)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func stopButtonClick(_ sender: UIButton) {
        stopTimer()
        eventType = .stop
        setupButtonUI()
    }
    
    // MARK: - Timer Helper Methods
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    self.updateLabel()
                } else {
                    self.stopTimer()
                    self.eventType = .stop
                    self.setupButtonUI()
                }
            }
            RunLoop.current.add(timer!, forMode: .common)
        }
        isRunning = true
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func updateLabel() {
        self.lblTimer.text = remainingSeconds.toTimeString
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
