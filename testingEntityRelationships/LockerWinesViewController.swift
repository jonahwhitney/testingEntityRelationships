//
//  LockerWinesViewController.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/18/24.
//

import UIKit

class LockerWinesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var wineTable: UITableView!

    @IBOutlet weak var lockerOwner: UITextView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // lockers to be filtered
    var items: [Locker]?
    
    // Data for the table
    var wines: [Wine]?
    
    // variable for specific wine selected
    var selectedWine: Wine?
    
    // vars to store strings passed from selection
    var lockerNumber = ""
    var lockerName = ""
    
    // var for the locker that is selected
    var thisLocker: Locker!
    
    // var for wine to be reduced by in reduceWineQuantityMultiple method
    var reduceByQuantity: Int64!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // testing that string was passed into lockerNumber
        // print(lockerNumber) - it worked!
        
        wineTable.delegate = self
        wineTable.dataSource = self
            
        // testing that data was filtered
        fetchLocker()
        
        // call to fetchWines to display in tableView
        fetchWines()
    }
    
    // MARK: - Data Methods
    
    func fetchLocker () {
        
        // Fetch the data from core data
        let request = Locker.fetchRequest()
        
        // set the filtering criteria
        let pred = NSPredicate(format: "number == %@", lockerNumber)
        request.predicate = pred
        
        do {
            self.items = try context.fetch(request)
            // print(items!) // - testing filtering
            
            // reload the table with new data that is added
            DispatchQueue.main.async {
                self.wineTable.reloadData()
            }
            
            
        }
        catch {
            print("Error retrieving data.")
        }
        
        // set the text at top of screen
        lockerOwner.text = "Locker #\(lockerNumber) - \(lockerName)"
        
        // set thisLocker to specific locker that was selected on previous screen
        thisLocker = items![0]
        wines = (thisLocker.wines?.allObjects as? [Wine])
        
        print(wines!.count, thisLocker.wines!.count)
    }
    
    // get wines from thisLocker
    func fetchWines () {
        
        // fetch the data from core data
        let request = Wine.fetchRequest()
        
        // set the filtering criteria
        let pred = NSPredicate(format: "locker == %@", thisLocker)
        request.predicate = pred
        
        // set the sorting criteria
        let sort = NSSortDescriptor(key: "color", ascending: false)
        request.sortDescriptors = [sort]
        
        // Fetch the data to display in the tableView
        do {
            self.wines = try context.fetch(request)
            
            // reload the table with new data that is added
            DispatchQueue.main.async {
                self.wineTable.reloadData()
            }
            
        }
        catch {
            print("Error retrieving data.")
        }
        
    }
    
    @IBAction func addWineTapped(_ sender: UIButton) {
        // create pop up to take info
        let alert = UIAlertController(title: "Add new wine", message: "Wine information", preferredStyle: .alert)

        // make text field entries with placeholder text for prompts
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Name"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Color"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Variety"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Month Ordered"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Year Ordered"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Price"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Quantity"
        })
        
        // make the buttons on the alert
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submit = UIAlertAction(title: "Add", style: .default, handler: { action in
            
            // get the entered data
            let wineName = alert.textFields![0]
            let wineColor = alert.textFields![1]
            let wineType = alert.textFields![2]
            let wineMonth = alert.textFields![3]
            let wineYear = alert.textFields![4]
            let winePrice = alert.textFields![5]
            let wineQuantity = alert.textFields![6]
            let wineLocker = self.thisLocker
            
                       
            // create wine object
            let newWine = Wine(context: self.context)
            newWine.name = wineName.text
            newWine.color = wineColor.text
            newWine.type = wineType.text
            newWine.monthAndYearOrdered = "\(wineMonth) \(wineYear)"
            newWine.price = Float(winePrice.text!) ?? 0
            newWine.quantity = Int64(wineQuantity.text!) ?? 1
            newWine.locker = wineLocker
            
            // add wine to locker
            self.thisLocker.addToWines(newWine)
            
            // save the data
            do {
                try self.context.save()
            }
            catch {
                print("error saving the data")
            }
            // re-fetch the data
            self.fetchWines()
            
        })
        alert.addAction(cancel)
        alert.addAction(submit)
        
        self.present(alert, animated: true)
    }
    
    // method for deleting wine
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completionHandler) in
        
            // select wine to remove
            let wineToDelete = self.wines![indexPath.row]
            
            // remove the wine
            self.context.delete(wineToDelete)
            
            // save the data
            do {
                try self.context.save()
            }
            catch {
                print("Error deleting data.")
            }
            
            // re-fetch the data
            self.fetchWines()
            
            
        })
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // method for updating wine
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "Edit Wine Information", handler: { (action, view, completionHandler) in
            
            // select locker to update
            let wine = self.wines![indexPath.row]
            
            // create pop up to take info
            let alert = UIAlertController(title: "Update Wine Info", message: "Enter new information", preferredStyle: .alert)

            // make text field entries with placeholder text for prompts
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Name"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Color"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Variety"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Month Ordered"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Year Ordered"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Price"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Quantity"
            })
            
            // make the buttons on the alert
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let submit = UIAlertAction(title: "Add", style: .default, handler: { action in
                
                // get the entered data
                let wineName = alert.textFields![0]
                let wineColor = alert.textFields![1]
                let wineType = alert.textFields![2]
                let wineMonth = alert.textFields![3]
                let wineYear = alert.textFields![4]
                let winePrice = alert.textFields![5]
                let wineQuantity = alert.textFields![6]
                let wineLocker = self.thisLocker
                           
                // update locker object
                wine.name = wineName.text
                wine.color = wineColor.text
                wine.type = wineType.text
                wine.monthAndYearOrdered = "\(wineMonth) \(wineYear)"
                wine.price = Float(winePrice.text!) ?? 0
                wine.quantity = Int64(wineQuantity.text!) ?? 1
                wine.locker = wineLocker
                
                
                // save the data
                do {
                    try self.context.save()
                }
                catch {
                    print("error saving the data")
                }
                // re-fetch the data
                self.fetchWines()
                
            })
            alert.addAction(cancel)
            alert.addAction(submit)
            
            self.present(alert, animated: true)
            
            
        })
        
        // make background of action blue?
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // method for removing wine from locker (update the quantity)
    func reduceWineQuantity(quantity: Int64) -> Int64 {
        // make var for current wine quantity that will be reduced
        var wineQuantity = quantity
        // reduce the wineQuantity by 1
        wineQuantity -= 1
        
        return wineQuantity
    }
    
    func reduceWineQuantityMultiple(quantity: Int64) -> Int64 {
        
        // make var for current wine quantity that will be reduced
        var wineQuantity = quantity
        
        // reduce the quantity
        wineQuantity -= self.reduceByQuantity
        
        return wineQuantity
    }
    
    func removeWineActionSheet() {
        
        let actionSheet = UIAlertController(title: "Bottle Selected", message: "Remove from locker?", preferredStyle: .actionSheet)
        
        // make the buttons on the actionSheet
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let removeBottles = UIAlertAction(title: "Remove Bottles", style: .default, handler: {
            action in
            
            let wineQuantity = self.selectedWine?.quantity
            
            let alert = UIAlertController(title: "Remove Bottles", message: "How many Bottles would you like to remove?", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Quantity"
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let removeMultipleAction = UIAlertAction(title: "Remove Bottles", style: .default, handler: {
                action in
                
                
                // capture the field input
                let numberOfBottlesToRemove = alert.textFields![0]
                // set the input to var to reduce as Int64
                let numberOfBottlesToRemoveInt = Int64(numberOfBottlesToRemove.text!) ?? 1
                self.reduceByQuantity = numberOfBottlesToRemoveInt
                                
                self.selectedWine!.quantity = self.reduceWineQuantityMultiple(quantity: wineQuantity ?? 1)
                
                print("alert button tapped")
                
                // save the data
                do {
                    try self.context.save()
                }
                catch {
                    print("error saving the data")
                }
                
                self.fetchWines()
            })
            
            alert.addAction(cancel)
            alert.addAction(removeMultipleAction)
            
            self.present(alert, animated: true)
        
        })
        
        actionSheet.addAction(cancel)
        actionSheet.addAction(removeBottles)
        
        self.present(actionSheet, animated: true)
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wines?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath)
        
        let wine = self.wines![indexPath.row]
        cell.textLabel?.text = "\(wine.name!) \(wine.type!) - QTY:\(wine.quantity)"
        
        if wine.color == "Red" {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.1)
        } else if wine.color == "Other" {
            cell.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set the wine that is tapped to the selectedWine variable
        selectedWine = (wines![indexPath.row])
        
        
        removeWineActionSheet()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
