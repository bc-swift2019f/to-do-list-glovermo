//
//  ViewController.swift
//  To Do List
//
//  Created by Morgan Glover on 9/22/19.
//  Copyright © 2019 Morgan Glover. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var defaultsData = UserDefaults.standard
    var toDoArray = [String]()
    var toDoNotesArray = [String]()
//    var toDoArray = ["Learn Swift", "Build Apps", "Change the World!"]
//    var toDoNotesArray = ["I should be certain to do all of the exercises at the end of the chapters before the exam.", "Take my ideas to the school's venture competition and win the big check.", "Focus apps on empowerment for all, with an extra bonus for users who are kind."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        toDoArray = defaultsData.stringArray(forKey: "toDoArray") ?? [String]()
        toDoNotesArray = defaultsData.stringArray(forKey: "toDoNotesArray") ?? [String]()
    }
    
    func saveDefaultsData () {
        defaultsData.set(toDoArray, forKey: "toDoArray")
        defaultsData.set(toDoNotesArray, forKey: "toDoNotesArray")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditItem" {
            let destination = segue.destination as! DetailViewController
            let index = tableView.indexPathForSelectedRow!.row
            destination.toDoItem = toDoArray[index]
            destination.toDoNotesItem = toDoNotesArray[index]
        } else {
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedPath, animated: false)
            }
        }
        saveDefaultsData()
    }
    
    @IBAction func unwindFromDetailViewController(segue: UIStoryboardSegue) {
        let sourceViewController = segue.source as! DetailViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            toDoArray[indexPath.row] = sourceViewController.toDoItem!
            toDoNotesArray[indexPath.row] = sourceViewController.toDoNotesItem!
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: toDoArray.count, section: 0)
            toDoArray.append(sourceViewController.toDoItem!)
            toDoNotesArray.append(sourceViewController.toDoNotesItem!)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing { // If button clicked while editing, I’m done
            tableView.setEditing(false, animated: true) // turn off tableView editing
            editBarButton.title = "Edit" // set button label so it can re-start edit
            addBarButton.isEnabled = true // enable the “+” button
        } else { // I wasn’t editing, so start editing
            tableView.setEditing(true, animated: true) // turn on tableView editing
            editBarButton.title = "Done" // set button label so it can stop edit
            addBarButton.isEnabled = false // disable the “+” button, don’t add if editing
        }

    }
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = toDoArray[indexPath.row]
        cell.detailTextLabel?.text = toDoNotesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoArray.remove(at: indexPath.row)
            toDoNotesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveDefaultsData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // first make a copy of the item that you are going to move
        let itemToMove = toDoArray[sourceIndexPath.row]
        // delete item from the original location (pre-move)
        let noteToMove = toDoNotesArray[sourceIndexPath.row]
        toDoArray.remove(at: sourceIndexPath.row)
        toDoNotesArray.remove(at: sourceIndexPath.row)
        // Insert item into the “to”, post-move, location
        toDoArray.insert(itemToMove, at: destinationIndexPath.row)
        toDoNotesArray.insert(noteToMove, at: destinationIndexPath.row)
        saveDefaultsData()
    }
}
