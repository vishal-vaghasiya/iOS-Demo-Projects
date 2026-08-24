//
//  QuotesVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 10/10/25.
//


import UIKit

struct QuoteCategory: Codable {
    let category: String
    let color: String
    let quotes: [String]
}

struct QuotesData: Codable {
    let categories: [QuoteCategory]
}

class QuotesVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var quotesTV: UITableView!
    
    // MARK: - PROPERTY
    var quotesList: [QuoteCategory] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Status Messages"
        self.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadQuotesJSON()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        self.quotesTV.register(UINib(nibName: QuotesTVCell.identifier, bundle: nil), forCellReuseIdentifier: QuotesTVCell.identifier)
    }
    
    func loadQuotesJSON() {
        if let url = Bundle.main.url(forResource: "Status", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(QuotesData.self, from: data)
                self.quotesList = decoded.categories
                DispatchQueue.main.async {
                    self.quotesTV.reloadData()
                }
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}

extension QuotesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuotesTVCell.identifier, for: indexPath) as! QuotesTVCell
        let category = quotesList[indexPath.row]
        cell.lblName?.text = category.category
        cell.lblName?.textColor = .black
        if let color = UIColor(hex: category.color) {
            cell.lblName.backgroundColor = color
        } else {
            cell.lblName.backgroundColor = .lightGray // fallback color
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = quotesList[indexPath.row]
        let vc = StoryboardScene.Quotes.viewQuotesVC.instantiate()
        vc.quotes = quotesList[indexPath.row].quotes
        if let color = UIColor(hex: category.color) {
            vc.colorOfCategory = color
        } else {
            vc.colorOfCategory = .lightGray
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
