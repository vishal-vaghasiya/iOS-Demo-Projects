//
//  PrivateNotesVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 09/10/25.
//

import UIKit
import CoreData

class PrivateNotesVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var notesTV: UITableView!
    
    // MARK: - PROPERTY
    var notes: [Notes] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchNotes()
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
    func setupUI(){
        self.notesTV.register(UINib(nibName: NoteTVCell.identifier , bundle: nil), forCellReuseIdentifier: NoteTVCell.identifier)
    }
    
    // MARK: - FETCH NOTES
    func fetchNotes() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            notes = try context.fetch(fetchRequest)
            notesTV.reloadData()
        } catch {
            print("Failed to fetch notes: \(error)")
        }
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func editButtonClick(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func addButtonClick(_ sender: UIBarButtonItem) {
        let vc = StoryboardScene.PrivateNotes.createNoteVC.instantiate()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - OTHER
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension PrivateNotesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTVCell.identifier, for: indexPath) as! NoteTVCell
        let note = notes[indexPath.row]
        cell.configure(with: note) // NoteTVCell should accept Notes object
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNote = notes[indexPath.row]
        let vc = StoryboardScene.PrivateNotes.createNoteVC.instantiate()
        vc.noteToEdit = selectedNote
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToDelete = notes[indexPath.row]
            
            // Delete from Core Data
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            context.delete(noteToDelete)
            
            do {
                try context.save()
                // Remove from array and update table view
                notes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete note: \(error)")
            }
        }
    }
}
