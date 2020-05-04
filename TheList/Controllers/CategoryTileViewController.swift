//
//  CategoryTileViewController.swift
//  TheList
//
//  Created by Nenad Matic on 22/03/2020.
//  Copyright © 2020 Nenad Matic. All rights reserved.
//

import UIKit
import  CoreData

class CategoryTileViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
        navColor = navigationController?.navigationBar.barTintColor
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        var index = 0
        for _ in categories {
            categoryTiles[index].text = categories[index].name
            index += 1
        }
        
        var num = 0
        
        for i in categoryTiles {
            
            i.textAlignment = .center
            i.font = .boldSystemFont(ofSize: 35)
            categoryTiles[num].delegate = self
            categoryTiles[num].addGestureRecognizer(longPressGesture())
            categoryTiles[num].addGestureRecognizer(onePress())
            if i.text == "" {
                i.isHidden = true
            }
            
            num += 1
        }
        
        if categories.count != 0 {
            self.initialLabel.isHidden = true
        }
    }
 
    
    var navColor: UIColor?
    
    //SET NAV BAR COLOR BACK TO DEFAULT AFTER RETURNING FROM ITEMS
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = navColor
    }
    
    //GESTURE RECOGNIZERS - PRESS TO NAVIGATE TO ITEMS, LONG PRESS TO DELETE CATEGORY
    func onePress () -> UITapGestureRecognizer {
        let onePress = UITapGestureRecognizer(target: self, action: #selector(press(sender:)))
        
        return onePress
    }
    
    func longPressGesture () -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(long(sender:)))
        
        return longPress
    }
    
    var categorySelected: Category?
    var viewSelected: UITextField?
    
    
    @objc func press (sender : UITapGestureRecognizer) {
        
        let sourceView = sender.view as? UITextField
        let nameView = sourceView?.text
        //let viewTag = sourceView?.tag
        for i in categoryTiles {
             if i.text == nameView {
            //if i.tag == viewTag {
                //categorySelected = categories.first(where: {$0.name == i.text!})!
                categorySelected = categories.first(where: {$0.name == nameView!})!
           
            viewSelected = i
            }
           // }
        }
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemsTableViewController
        destinationVC.categorySelected = categorySelected
        destinationVC.categoryColor = viewSelected?.backgroundColor
        destinationVC.categoryBar = navColor
    }
    
    
    @objc func long (sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Delete Category", message: nil, preferredStyle: .alert)
        let sourceView = sender.view as? UITextField
        let nameView = sourceView?.text
        //let viewTag = sourceView?.tag
        
        let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            for i in self.categoryTiles {
                //if i.tag == viewTag {
                    
                   // self.context.delete(self.categories.first(where: {$0.name == i.text!})!)
                   // self.categories.removeAll(where: {$0.name == i.text!})
                 if i.text == nameView {
                self.context.delete(self.categories.first(where: {$0.name == nameView!})!)
                self.categories.removeAll(where: {$0.name == nameView!})
                
                //}
               
               
                }
                 i.text = ""
            }
            self.saveCategory()
            self.viewDidLoad()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    
    // ADD CATEGORY. IMPLEMENTED CHECK IF SAME ALREADY EXISTS, IF IT DOES, INFO MESSAGE WILL POP UP AND PREVENT DUPLICATION
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var tileIndex = 0
        var userInput = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            for i in self.categories {
                if userInput.text == i.name {
                    let blockAlert = UIAlertController(title: "Duplicate Category", message: "Category with the same name already exists.", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default) { (OK) in
                        
                    }
                    blockAlert.addAction(OK)
                    self.present(blockAlert, animated: true)
                }
            }
            
            if self.presentedViewController == nil {
            self.categoryTiles[tileIndex].isHidden = false
            self.categoryTiles[tileIndex].text = userInput.text
            self.initialLabel.isHidden = true
            
            let newCategory = Category(context: self.context)
            newCategory.name = userInput.text
            self.categories.append(newCategory)
            self.saveCategory()
            //self.loadCategory()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        
        alert.addTextField { (field) in
            NotificationCenter.default.addObserver(forName: nil, object: field, queue: OperationQueue.main) { (notification) in
            if field.text == "" {
                action.isEnabled = false
            } else {
                action.isEnabled = true
            }
            userInput = field
            field.placeholder = "Add Category..."
        }
        }
       
        alert.addAction(cancel)
        alert.addAction(action)
        
        let emptyTile = self.categoryTiles.first(where: {$0.text == ""})
         if emptyTile != nil {
        self.present(alert, animated: true, completion: {
                tileIndex = emptyTile!.tag
        
    })
    }   else {
            let fullAlert = UIAlertController(title: "Category section full", message: "Maximum of 8 categories has been reached. You need to delete one of the existing categories in order to add a new one.", preferredStyle: .alert)
            let blockAction = UIAlertAction(title: "OK", style: .default) { (action) in
                
            }
            fullAlert.addAction(blockAction)
            self.present(fullAlert, animated: true)
        }
    }
    
    
    @IBOutlet var categoryTiles: [UITextField]!
    
    @IBOutlet weak var initialLabel: UILabel!
    
    //CLEAR ALL CATEGORIES. IMPLEMENTED CONFIRMATION WINDOW
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Clear All", message: "Are you sure you want to clear all categories?", preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete All", style: .destructive) { (delete) in
            var num = self.categories.count
            while num > 0 {
                num -= 1
                self.context.delete(self.categories[num])
                self.categories.remove(at: num)
                self.categoryTiles[num].isHidden = true
            }
            self.initialLabel.isHidden = false
            self.saveCategory()
           
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            
        }
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // SAVE
    
    func saveCategory () {
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        
    }
    
    //LOAD
    
    func loadCategory () {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        
    }
}

