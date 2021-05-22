//
//  ProductTVC.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductTVC: UITableViewController {
    
    // create a folder array to populate the table
    var products = [Product]()
    
    // create a context to work with core data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // define a search controller
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        createProducts()
        
        showSearchBar()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product_cell", for: indexPath)
        
        cell.textLabel?.text = products[indexPath.row].name! + " (" + products[indexPath.row].id! + ")"
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.text = "$" + String(format: "%.2f", Double(products[indexPath.row].price))
//        cell.imageView?.image = UIImage(named: products[indexPath.row].id!).wid
//        cell.imageView?.sizeThatFits(CGSize(width: 200, height: 50))
        cell.selectionStyle = .none
        
        return cell
    }
    
    /// load folder from core data
    func loadProducts(predicate: NSPredicate? = nil) {
        
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if (predicate != nil) {
            request.predicate = predicate
        }
        

        
        do {
            products = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        tableView.reloadData()
        

    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? ProductVC {
            
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destination.selectedProduct = products[index]

                }
            }
        }
        
    }
    
    func createProducts(){
        do {
            let request: NSFetchRequest<Product> = Product.fetchRequest()

            products = try context.fetch(request)
        } catch {
            print("Error loading folders \(error.localizedDescription)")
        }
        for prod in products{
            context.delete(prod)
        }
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the folder \(error.localizedDescription)")
        }
        loadProducts()
        for item in prodData {
            let dictionary = item as [String : Any]
            let productsIds = self.products.map({$0.id})
            if !productsIds.contains(dictionary["id"]  as? String){
                let newProduct = Product(context: self.context)
                newProduct.id = dictionary["id"] as? String
                newProduct.name = dictionary["name"] as? String
                newProduct.p_description = dictionary["p_description"] as? String
                newProduct.price = dictionary["price"] as! Double
                newProduct.provider = dictionary["provider"] as? String
                
                products.append(newProduct)
                
            }
        }
        if products.count > 0 {
            do {
                try context.save()
                tableView.reloadData()
            } catch {
                print("Error saving the folder \(error.localizedDescription)")
            }
        }

    }

    
    //MARK: - show search bar func
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Product"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
}

////MARK: - search bar delegate methods
extension ProductTVC: UISearchBarDelegate {


    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        loadProducts(predicate: predicate)
    }


    /// when the text in text bar is changed
    /// - Parameters:
    ///   - searchBar: search bar is passed to this function
    ///   - searchText: the text that is written in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadProducts()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
