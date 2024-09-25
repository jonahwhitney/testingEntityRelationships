//
//  MonthViewController.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/16/24.
//

import UIKit

class MonthViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var items: [Month]?
    
    // var for selected month
    var monthSelected = ""

    @IBOutlet weak var monthTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        monthTable.delegate = self
        monthTable.dataSource = self
        
        fetchMonths()
    }
    
    // // setting up button to add data when tapped
    @IBAction func addMonthTapped(_ sender: UIButton) {
        
        // create pop up to take info
        let alert = UIAlertController(title: "Add Month", message: "Month Ordered", preferredStyle: .alert)

        // make text field entries with placeholder text for prompts
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Locker number"
        })
        alert.addTextField(configurationHandler: { field in
            field.placeholder = "Owner Name"
        })
        
        // make the buttons on the alert
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submit = UIAlertAction(title: "Add", style: .default, handler: { action in
            
            // get the entered data
            let month = alert.textFields![0]
            let year = alert.textFields![1]
                       
            // create wine object
            let newMonth = Month(context: self.context)
            newMonth.nameMonth = "\(month.text!) \(year.text!)"
            
            
            // save the data
            do {
                try self.context.save()
            }
            catch {
                print("error saving the data")
            }
            // re-fetch the data
            self.fetchMonths()
            
        })
        alert.addAction(cancel)
        alert.addAction(submit)
        
        self.present(alert, animated: true)
        
    }
    
    func fetchMonths () {
        
        // Fetch the data from core data to display in the tableView
        do {
            self.items = try context.fetch(Month.fetchRequest())
            
            // reload the table with new data that is added
            DispatchQueue.main.async {
                self.monthTable.reloadData()
            }
            
        }
        catch {
            print("Error retrieving data.")
        }
        
    }
    
    // method to delete month
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completionHandler) in
        
            // select wine to remove
            let monthToDelete = self.items![indexPath.row]
            
            // remove the wine
            self.context.delete(monthToDelete)
            
            // save the data
            do {
                try self.context.save()
            }
            catch {
                print("Error deleting data.")
            }
            
            // re-fetch the data
            self.fetchMonths()
            
            
        })
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // method for updating month info
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "Edit Wine Information", handler: { (action, view, completionHandler) in
            
            // select month to update
            let monthOrdered = self.items![indexPath.row]
            
            // create pop up to take info
            let alert = UIAlertController(title: "Add Month", message: "Month Ordered", preferredStyle: .alert)

            // make text field entries with placeholder text for prompts
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Month Ordered"
            })
            alert.addTextField(configurationHandler: { field in
                field.placeholder = "Year"
            })
            
            // make the buttons on the alert
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let submit = UIAlertAction(title: "Add", style: .default, handler: { action in
                
                // get the entered data
                let month = alert.textFields![0]
                let year = alert.textFields![1]
                           
                // update month object
                monthOrdered.nameMonth = "\(month.text!) \(year.text!)"
                
                
                // save the data
                do {
                    try self.context.save()
                }
                catch {
                    print("error saving the data")
                }
                // re-fetch the data
                self.fetchMonths()
                
            })
            alert.addAction(cancel)
            alert.addAction(submit)
            
            self.present(alert, animated: true)
            
            
        })
        
        // make background of action blue?
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // MARK: - Table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "monthCell", for: indexPath)
        
        // get wine from items and set label
        let month = self.items![indexPath.row]
        
        cell.textLabel?.text = "\(month.nameMonth!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Month Ordered"
    }
    
    
    // MARK: - Navigation, Segue into month's wines
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         // setting selected locker to be the number from the selected row
         monthSelected = (items?[indexPath.row].nameMonth)!
         // print(monthSelected) // testing selection
         
         performSegue(withIdentifier: "monthDetail", sender: nil)
     }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let viewController = segue.destination as? WineOfMonthViewController {
            // Pass the selected object to the new view controller.
            viewController.monthYear = monthSelected
        }
        
    }
    
    
    

}
