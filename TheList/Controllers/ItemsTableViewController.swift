//
//  ItemsTableViewController.swift
//  TheList
//
//  Created by Nenad Matic on 15/03/2020.
//  Copyright © 2020 Nenad Matic. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ItemsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        
    }
    
    var outstandingItems = [Item]()
    var doneItems = [Item]()
    
    var itemArray = [Item]()
    
    var categorySelected : Category? {
        
        willSet{
            navigationItem.title = newValue?.name
        }
        didSet {
            loadItems()
          
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller not loaded yet.")}
        navBar.barTintColor = categoryColor
    }
    
    var categoryColor: UIColor?
    var categoryBar: UIColor?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? CategoryTileViewController
        destinationVC?.navColor = categoryBar
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        var userInput = UITextField()
        
        let alert = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            for i in self.itemArray {
                if i.title == userInput.text {
                    let blockAlert = UIAlertController(title: "Duplicate Item", message: "Item with the same name already exists.", preferredStyle: .alert)
                    let blockAction = UIAlertAction(title: "OK", style: .default) { (action) in }
                    
                    blockAlert.addAction(blockAction)
                    self.present(blockAlert, animated: true)
                }
            }
            
            if self.presentedViewController == nil {
                
            let newItem = Item(context: self.context)
            newItem.title = userInput.text
            newItem.isDone = false
            newItem.parentCategory = self.categorySelected
            self.itemArray.append(newItem)
            
            self.saveItem()
            self.loadItems()
        }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            return
        }
        
        alert.addTextField { (field) in
            NotificationCenter.default.addObserver(forName: nil, object: field, queue: OperationQueue.main) { (notification) in
                if field.text == "" {
                    action.isEnabled = false
                } else {
                    action.isEnabled = true
                }
                userInput = field
                field.placeholder = "Add Item..."
            }
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    //SAVE
    func saveItem () {
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    
    //LOAD
    
    func loadItems() {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categorySelected!.name!)
        
        request.predicate = categoryPredicate
        
        do {
            itemArray = try context.fetch(request)
            
        } catch {
            print(error)
        }
        
        doneItems = []
        outstandingItems = []
        
        
        for i in itemArray {
            if i.isDone {
                doneItems.append(i)
            } else {
                outstandingItems.append(i)
            }
        }
        
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
        
    }
    
    // MARK: - Table view data source
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if doneItems.isEmpty {
            return 1
        } else {
            return 2
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return outstandingItems.count
        } else {
            return doneItems.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = .opaqueSeparator

        let sectionLabel = UILabel(frame: CGRect(x: 8, y: 26, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont(name: "Helvetica", size: 17)
        sectionLabel.textColor = UIColor.black
        if section == 0 {
             sectionLabel.text = "To Do"
        } else {
            sectionLabel.text = "Done"
        }
       
        sectionLabel.sizeToFit()
        headerView.addSubview(sectionLabel)

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 27)
        
        cell.accessoryType = indexPath.section == 0 ? .none : .checkmark
        
        cell.textLabel?.text = indexPath.section == 0 ? outstandingItems[indexPath.row].title : doneItems[indexPath.row].title
       // cell.textLabel?.font = .monospacedDigitSystemFont(ofSize: 25, weight: .semibold)
        
        return cell
        
    }
    
    //EDITING CELL, ADDING CHECKMARK, MOVING TO BOTTOM WHEN CHECKED
    var soundPlayer = SoundPlayer()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
     //   itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        
        if indexPath.section == 0 {
            outstandingItems[indexPath.row].isDone = !outstandingItems[indexPath.row].isDone
        
            
            soundPlayer.playSound(with: "insight")
        } else {
            doneItems[indexPath.row].isDone = !doneItems[indexPath.row].isDone
            soundPlayer.playSound(with: "springy-incident")
        }
        
        itemArray = outstandingItems + doneItems
        
        saveItem()
        loadItems()
       
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
           if indexPath.section == 0 {
            context.delete(outstandingItems[indexPath.row])
              outstandingItems.remove(at: indexPath.row)
            
            } else {
             context.delete(doneItems[indexPath.row])
                doneItems.remove(at: indexPath.row)
           
            }
            
           itemArray = outstandingItems + doneItems
            
            saveItem()
            loadItems()
            
        }
    }
    
}
