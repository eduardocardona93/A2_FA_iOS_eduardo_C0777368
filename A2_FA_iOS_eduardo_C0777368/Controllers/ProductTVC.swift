//
//  ProductTVC.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductTVC: UITableViewController {

    var products = [Product]() // create the product array to populate the table
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // create the context to work with core data
    let searchController = UISearchController(searchResultsController: nil) // define the search controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createProducts() // loads the products if exist, otherwise create them from the prodData array (check ProductsData.swift)
        showSearchBar() // shows and sets the search bar
        performSegue(withIdentifier: "toDetailView", sender: self) // shows the first element of the database
    }
   

    // MARK: - Table view functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "product_cell", for: indexPath) // gets the cell element
        cell.textLabel?.text = products[indexPath.row].name! + " (" + products[indexPath.row].id! + ")" // sets the title as the product name and id
        cell.detailTextLabel?.text = "$" + String(format: "%.2f", Double(products[indexPath.row].price))  // sets the detail as the product price

        if indexPath.row % 2 != 0{ // every 2th set the style to have an striped table
            cell.backgroundColor = .systemBlue //sets background blue
            cell.textLabel?.textColor = .white // sets title label color as white
            cell.detailTextLabel?.textColor = .white // sets detail label color as white
        }else{
            cell.backgroundColor = .white //sets background blue
            cell.textLabel?.textColor = .systemBlue  // sets title label color as blue
            cell.detailTextLabel?.textColor = .systemBlue  // sets detail label color as blue
        }
        
        return cell
    }
    // MARK: - Save and load functions
    // loads products from core data
    func loadProducts(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Product> = Product.fetchRequest() // get the request object
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort the request by name
        if (predicate != nil) { // in case there is a predicate
            request.predicate = predicate // set it to the request
        }
        do {
            products = try context.fetch(request) // fetch into the context and asign it to the products variable
        } catch {
            print("Error loading products \(error.localizedDescription)") // in case of error print the error
        }
        tableView.reloadData() // reloads the table data
    }
    
    // saves products to the core data
    func createProducts(){
        loadProducts() // loads the existing data
        for item in prodData { // iterates the prodData array (check ProductsData.swift)
            let dictionary = item as [String : Any] // cast it as a dictionary
            let productsIds = self.products.map({$0.id}) // gets the product ids as an array
            if !productsIds.contains(dictionary["id"]  as? String){ // validates if the item id is already set
                let newProduct = Product(context: self.context) // creates a new product object
                newProduct.id = dictionary["id"] as? String // sets the id
                newProduct.name = dictionary["name"] as? String // sets the name
                newProduct.p_description = dictionary["p_description"] as? String // sets the description
                newProduct.price = dictionary["price"] as! Double // sets the price
                newProduct.provider = dictionary["provider"] as? String // sets the provider
                products.append(newProduct) // appends it to the products array
            }
        }
        if products.count > 0 { // validates if there is at least 1 new product
            do {
                try context.save() // saves the context
            } catch {
                print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
            }
        }
    }
    
    //MARK: - segue functions
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductVC { // Get the new view controller using segue.destination. and validates if it is Product view
            if let cell = sender as? UITableViewCell { // validates if the sender is a cell and gets the object
                if let index = tableView.indexPath(for: cell)?.row { // gets the index of the selected product
                    destination.selectedProduct = products[index] // Pass the selected product to the new view controller.
                }
            }else{
                destination.selectedProduct = products.first // Pass the first product to the new view controller.
            }
        }
    }
    //MARK: - search bar functiion
    func showSearchBar() {
        searchController.searchBar.delegate = self // sets the delegate
        searchController.obscuresBackgroundDuringPresentation = false // sets false the obscure bg during presentation
        searchController.searchBar.placeholder = "Search Product" // sets the search bar placeholder
        navigationItem.searchController = searchController // sets the search bar controller
        definesPresentationContext = true // sets the presentation context
        searchController.searchBar.searchTextField.textColor = .lightGray // sets the search bar text color
    }
}

//MARK: - search bar delegate methods
extension ProductTVC: UISearchBarDelegate {
    // when the text in text bar is changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { // if the search bar is empty
            loadProducts() // load all the products
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            // add predicate, if the name and the description contains the search bar text
            let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!, "p_description", searchBar.text!] )
            loadProducts(predicate: predicate)  // loads products from core data
        }
    }

}
