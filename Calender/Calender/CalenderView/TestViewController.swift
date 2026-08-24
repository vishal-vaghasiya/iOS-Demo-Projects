//
//  TestViewController.swift
//  JTAppleCalendar iOS
//
//  Created by Jay Thomas on 2017-07-11.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet var calendarView: JTACMonthView!
    @IBOutlet var theView: UIView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }

    }
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        // 0 indexed array
        let year = Calendar.current.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else { return }
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        handleCellSelection(view: myCustomCell, cellState: cellState)
    }
    
    func handleCellSelection(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CellView else {return }
        if calendarView.allowsMultipleSelection {
        switch cellState.selectedPosition() {
        case .full: myCustomCell.backgroundColor = .green
        case .left: myCustomCell.backgroundColor = .yellow
        case .right: myCustomCell.backgroundColor = .red
        case .middle: myCustomCell.backgroundColor = .blue
        case .none: myCustomCell.backgroundColor = nil
        }
        } else {
            if cellState.isSelected {
                myCustomCell.backgroundColor = UIColor.red
            } else {
                myCustomCell.backgroundColor = UIColor.white
            }
        }
    }
    
    func handleCellTextColor(view: CellView, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            view.dayLabel.textColor = UIColor.black
        } else {
            view.dayLabel.textColor = UIColor.gray
        }
    }
    
    var iii: Date?
}


extension TestViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CellView
        configureCell(view: cell, cellState: cellState)
        /*if cellState.text == "1" {
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            cell.dayLabel .text = "\(month) \(cellState.text)"
        } else {
            cell.dayLabel .text = cellState.text
        }*/
        cell.dayLabel .text = cellState.text
        return cell
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2030 02 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,endDate: endDate)
        return parameters
    }
    
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        calendarView.viewWillTransition(to: size, with: coordinator, anchorDate: iii)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func handleCellConfiguration(cell: JTACDayCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
//        prePostVisibility?(cellState, cell as? CellView)
    }
    
}


