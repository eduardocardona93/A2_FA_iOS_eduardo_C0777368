//
//  ProviderProductsTVC.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-25.
//

import UIKit
import CoreData
class ProviderProductsTVC: UITableViewController {
    var providerProducts = [Product]() // list of provider products
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // create the context to work with core data
    
    var selectedProvider: Provider? {
        didSet { // when the provider is set
            loadProds() // load the products
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedProvider?.name // sets the view title as the provider name
    }
    
    func loadProds() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()  // get the request object
        // set the predicate for searching  products by the selected provider name
        let providerPredicate = NSPredicate(format: "parentProvider.name=%@", selectedProvider!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort the request by name
        request.predicate = providerPredicate // set the predicate to the request
        
        do {
            providerProducts = try context.fetch(request) // fetch into the context and asign it to the provider products variable
        } catch {
            print("Error loading notes \(error.localizedDescription)") // in case of error print the error
        }
        tableView.reloadData() // reloads the table data
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return providerProducts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prov_prod_cell", for: indexPath)
        cell.textLabel?.text = providerProducts[indexPath.row].name! // sets the title as the product name and id
        
        return cell
    }

    
    
}
