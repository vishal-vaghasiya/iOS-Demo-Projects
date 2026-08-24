//
//  ViewQuotesVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 10/10/25.
//

import UIKit
import Foundation
class ViewQuotesVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var quotesTV: UITableView!
    
    // MARK: - PROPERTY
    var quotes: [String] = []
    var colorOfCategory: UIColor = .clear
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        quotesTV.register(UINib(nibName: ViewQuoteTVCell.identifier, bundle: nil), forCellReuseIdentifier: ViewQuoteTVCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - UI SETUP
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK

    @objc func copyQuote(_ sender: UIButton) {
        let quote = quotes[sender.tag]
        UIPasteboard.general.string = quote
        let alert = UIAlertController(title: "Copied", message: "Quote copied to clipboard!", preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }

    @objc func shareQuote(_ sender: UIButton) {
        let quote = quotes[sender.tag]
        let activityVC = UIActivityViewController(activityItems: [quote], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

extension ViewQuotesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewQuoteTVCell.identifier, for: indexPath) as! ViewQuoteTVCell
        cell.lblQuote?.text = quotes[indexPath.row]
        cell.lblQuote?.numberOfLines = 0
        cell.lblQuote?.textColor = .black
        cell.lblQuote.backgroundColor = colorOfCategory
        
        cell.btnCopy.tag = indexPath.row
        cell.btnCopy.addTarget(self, action: #selector(copyQuote(_:)), for: .touchUpInside)
        cell.btnShare.tag = indexPath.row
        cell.btnShare.addTarget(self, action: #selector(shareQuote(_:)), for: .touchUpInside)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
