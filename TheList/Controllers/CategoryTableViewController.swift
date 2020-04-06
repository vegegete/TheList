//
//  CategoryTableViewController.swift
//  TheList
//
//  Created by Nenad Matic on 15/03/2020.
//  Copyright © 2020 Nenad Matic. All rights reserved.

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController, UITextFieldDelegate {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.rowHeight = 70
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    // SAVE
    
    func saveCategory () {
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        
        tableView.reloadData()
    }
    
    //LOAD
    
    func loadCategory () {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    //DELETE
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            context.delete(categories[indexPath.row])
                   categories.remove(at: indexPath.row)
                   self.saveCategory()
                   tableView.reloadData()
        }
    }
    
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var userInput = UITextField()
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if userInput.text != "" {
                
                let newCategory = Category(context: self.context)
                newCategory.name = userInput.text
                self.categories.append(newCategory)
                
            }
            
            self.saveCategory()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            return
        }
        
        action.isEnabled = false
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        alert.addTextField { (field) in
            
            // Observe the UITextFieldTextDidChange notification to be notified in the below block when text is changed
            NotificationCenter.default.addObserver(forName: nil, object: field, queue: OperationQueue.main) { (notification) in
                if field.text == "" {
                    action.isEnabled = false
                } else {
                    action.isEnabled = true
                }
            }
            userInput = field
            field.placeholder = "Add Category..."
            field.delegate = self
        }
        present(alert, animated: true)
    }
    
    func textFieldDidBeginEditing (_ textField: UITextField) {
             
           }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        cell.textLabel?.font = .boldSystemFont(ofSize: 30)
        cell.textLabel?.textAlignment = .center
        
        //let color = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.5)
        
        //cell.backgroundColor = color
        
        return cell
    }

    //SEGUE TO ITEMS
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           performSegue(withIdentifier: "GoToItemsDepr", sender: self)
    
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsTableViewController
        if let index = tableView.indexPathForSelectedRow {
        destinationVC.categorySelected = categories[index.row]
        }
    }
    
    
    
}
