//
//  ViewController.swift
//  testingEntityRelationships
//
//  Created by Jonah Whitney on 3/13/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var items: [Locker]?
    
    // vars for selected locker to be passed to next screen
    var selectedLocker = ""
    var selectedOwner = ""

    @IBOutlet weak var lockersTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        lockersTable.delegate = self
        lockersTable.dataSource = self
        
        fetchLockers()
    }
    
    // MARK: - CRUD methods

    // setting up button to add data when tapped
    @IBAction func addLockerTapped(_ sender: UIButton) {
        
        // create pop up to take info
        let alert = UIAlertController(title: "Add new locker", message: "Locker information", preferredStyle: .alert)

        // make 2 text field entries with placeholder text for prompts
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
            let lockerNumber = alert.textFields![0]
            let ownerName = alert.textFields![1]
                       
            // create wine object
            let newLocker = Locker(context: self.context)
            newLocker.owner = ownerName.text
            newLocker.number = lockerNumber.text
            
            
            // save the data
            do {
                try self.context.save()
            }
            catch {
                print("error saving the data")
            }
            // re-fetch the data
            self.fetchLockers()
            
        })
        alert.addAction(cancel)
        alert.addAction(submit)
        
        self.present(alert, animated: true)
    }
    
    func fetchLockers () {
        
        
        // Fetch the data from core data to display in the tableView
        do {
            
            // sort locker by number
            let request = Locker.fetchRequest()
            
            let sort = NSSortDescriptor(key: "number", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            
            // reload the table with new data that is added
            DispatchQueue.main.async {
                self.lockersTable.reloadData()
            }
            
        }
        catch {
            print("Error retrieving data.")
        }
        
    }
    
    // method for deleting locker
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completionHandler) in
        
            // select wine to remove
            let lockerToDelete = self.items![indexPath.row]
            
            // remove the wine
            self.context.delete(lockerToDelete)
            
            // save the data
            do {
                try self.context.save()
            }
            catch {
                print("Error deleting data.")
            }
            
            // re-fetch the data
            self.fetchLockers()
            
            
        })
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // method for updating locker info
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "Edit Wine Information", handler: { (action, view, completionHandler) in
            
            // select locker to update
            let locker = self.items![indexPath.row]
            
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
                let lockerNumber = alert.textFields![0]
                let ownerName = alert.textFields![1]
                           
                // update locker object
                locker.owner = ownerName.text
                locker.number = lockerNumber.text
                
                
                // save the data
                do {
                    try self.context.save()
                }
                catch {
                    print("error saving the data")
                }
                // re-fetch the data
                self.fetchLockers()
                
            })
            alert.addAction(cancel)
            alert.addAction(submit)
            
            self.present(alert, animated: true)
            
            
        })
        
        // make background of action blue?
        action.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lockerCell", for: indexPath)
        
        // get locker from items and set label
        let locker = self.items![indexPath.row]
        
        cell.textLabel?.text = "\(locker.number!) - \(locker.owner!)"
        
        return cell
    }
    
    // Setting header for Locker Table
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Locker number / Owner Name"
    }
    
    // MARK: Segue into locker details screen
    
    // Selecting locker
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // setting selected locker to be the number and owner from the selected row
        selectedLocker = (items?[indexPath.row].number)!
        selectedOwner = (items?[indexPath.row].owner)!
        // print(selectedLocker) // testing selection
        
        // segue to locker details
        performSegue(withIdentifier: "lockerDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let viewController = segue.destination as? LockerWinesViewController {
            viewController.lockerNumber = selectedLocker
            viewController.lockerName = selectedOwner
        }
        
    }
    
}

