//
//  WineOfMonthViewController.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/20/24.
//

import UIKit

class WineOfMonthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var month: UITextView!
    
    @IBOutlet weak var wineTable: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // lockers to be filtered
    var allMonths: [Month]?
    
    // data for the table
    var wines: [Wine]?
    
    // variable to pass string from previous screen
    var monthYear = ""
    
    // variable to reference specific month
    var thisMonth: Month!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // testing that string was passed into lockerNumber
        // print(monthYear)
        
        wineTable.delegate = self
        wineTable.dataSource = self
            
        // testing that data was filtered
        fetchMonth()
        
        fetchWines()
        
    }
    
    // MARK: Data methods
    
    // method to fetch specific locker
    func fetchMonth() {
        
        // Fetch the data from core data
        let request = Month.fetchRequest()
        
        // set the filtering criteria
        let pred = NSPredicate(format: "nameMonth == %@", monthYear)
        request.predicate = pred
        
        do {
            self.allMonths = try context.fetch(request)
            // print(items!) // - testing filtering
            
            // reload the table with new data that is added
            DispatchQueue.main.async {
                self.wineTable.reloadData()
            }
        }
        catch {
            print("Error retrieving data.")
        }
        
        // set the text at the top of the screen
        month.text = monthYear
        
        // set thisMonth to the month specified on the previous screen
        thisMonth = allMonths![0]
        // print(thisMonth.nameMonth!) testing that thisMonth was set properly
        wines = (thisMonth.wines?.allObjects as? [Wine])
        
    }
    
    func fetchWines () {
        
        // fetch the data from core data
        let request = Wine.fetchRequest()
        
        // set the filtering criteria
        let pred = NSPredicate(format: "month == %@", thisMonth)
        request.predicate = pred
        
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
    
    @IBAction func addWineTappedMonth(_ sender: UIButton) {
        print("pressed new wine")
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
            field.placeholder = "Price"
        })

        
        // make the buttons on the alert
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submit = UIAlertAction(title: "Add", style: .default, handler: { action in
            
            // get the entered data
            let wineName = alert.textFields![0]
            let wineColor = alert.textFields![1]
            let wineType = alert.textFields![2]
            let winePrice = alert.textFields![3]
                       
            // create wine object
            let newWine = Wine(context: self.context)
            newWine.name = wineName.text
            newWine.color = wineColor.text
            newWine.type = wineType.text
            newWine.price = Float(winePrice.text!) ?? 0
            
            // add wine to locker
            self.thisMonth.addToWines(newWine)
            
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
                field.placeholder = "Price"
            })
            
            // make the buttons on the alert
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let submit = UIAlertAction(title: "Add", style: .default, handler: { action in
                
                // get the entered data
                let wineName = alert.textFields![0]
                let wineColor = alert.textFields![1]
                let wineType = alert.textFields![2]
                let winePrice = alert.textFields![3]
                           
                // update locker object
                wine.name = wineName.text
                wine.color = wineColor.text
                wine.type = wineType.text
                wine.price = Float(winePrice.text!) ?? 0
                
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
    
    // MARK: Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wines?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath)
        
        // get wine from wines and set label
        let wine = self.wines![indexPath.row]
        
        cell.textLabel?.text = "\(wine.name!) \(wine.type!) - \(wine.color!)"
        
        return cell
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
