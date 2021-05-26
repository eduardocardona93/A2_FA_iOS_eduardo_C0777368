//
//  ProviderProductsTVC.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-25.
//

import UIKit
import CoreData
class ProviderProductsTVC: UITableViewController {
    var providerProducts = [Product]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // create the context to work with core data
    
    var selectedProvider: Provider? {
        didSet {
            loadProds()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedProvider?.name
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
    func loadProds() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        let providerPredicate = NSPredicate(format: "parentProvider.name=%@", selectedProvider!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = providerPredicate
        
        do {
            providerProducts = try context.fetch(request)
        } catch {
            print("Error loading notes \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    
}
