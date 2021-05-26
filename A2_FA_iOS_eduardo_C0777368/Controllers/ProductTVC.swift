//
//  ProductTVC.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductTVC: UITableViewController {
    // MARK: -  global constants
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // create the context to work with core data
    let searchController = UISearchController(searchResultsController: nil) // define the search controller
    // MARK: -  global variables
    var products = [Product]() // create the products array to populate the table
    var providers = [Provider]() // create the providers array to populate the table
    var selectedProduct: Product? = nil // selected product global variable definition
    var selectedProvider: Provider? = nil // selected provider global variable definition
    var productMode = true // product/provider mode global variable definition
    var selectMode = false // select mode global variable definition
    // MARK: -  view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProviders()// loads products from core data
        loadProducts()// loads providers from core data
        showSearchBar() // shows and sets the search bar
    }
    override func viewDidAppear(_ animated: Bool) {
        loadProviders()// loads products from core data
        loadProducts()// loads providers from core data
    }
    // MARK: - Action functions
    @IBAction func listEditClick(_ sender: Any) {
        selectMode = !selectMode // toggle select mode
        tableView.setEditing(selectMode, animated: true)
    }
    
    @IBAction func changeMode(_ sender: UIBarItem) {
        if productMode {
            navigationItem.title = "Providers" // sets the main title as Providers
            sender.image = UIImage(systemName: "list.bullet") // change the icon to indicate a list (products)
        }else{
            navigationItem.title = "Products" // sets the main title as Products
            sender.image = UIImage(systemName: "square.stack.3d.up.fill") // change the icon to indicate a group (providers)
        }
        productMode = !productMode // toggle product/provider mode
        tableView.reloadData() // reload tableview
    }
    // MARK: - Table view functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if productMode{
            return products.count // get the total products
        }else{
            return providers.count // get the total providers
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "view_cell", for: indexPath) // gets the cell element
        if productMode {
            cell.textLabel?.text = products[indexPath.row].name! // sets the title as the product name
            cell.detailTextLabel?.text = String((products[indexPath.row].parentProvider?.name)! )// sets the detail as the product provider
            cell.imageView!.image = nil
        }else{
            cell.textLabel?.text = providers[indexPath.row].name! // sets the title as the provider name and id
            cell.detailTextLabel?.text = String(providers[indexPath.row].products!.count )// sets the detail as the provider amount of products
            cell.imageView!.image = UIImage(systemName: "folder.fill")
        }
        
        if indexPath.row % 2 != 0{ // every 2th set the style to have an striped table
            cell.backgroundColor = .systemBlue //sets background blue
            cell.textLabel?.textColor = .white // sets title label color as white
            cell.detailTextLabel?.textColor = .white // sets detail label color as white
            cell.imageView!.tintColor =  .white
        }else{
            cell.backgroundColor = .white //sets background blue
            cell.textLabel?.textColor = .systemBlue  // sets title label color as blue
            cell.detailTextLabel?.textColor = .systemBlue  // sets detail label color as blue
            cell.imageView!.tintColor =  .systemBlue
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { // in case the editing style is delete
            if productMode { // if it is in product mode
                deleteProduct(product: products[indexPath.row]) // deletes the product selected
                products.remove(at: indexPath.row) // removes the product from the global list
                for (provider) in providers{ // iterates all the providers
                    if provider.products?.count == 0 { // validates if has no products
                        deleteProvider(provider: provider) // deletes the provider
                    }
                }
            }else{
                deleteProvider(provider: providers[indexPath.row]) // deletes the provider
                providers.remove(at: indexPath.row) // removes the provider from the global list
            }
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade) // removes rows from the list
            loadProviders()// loads products from core data
            loadProducts()// loads providers from core data
        } 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectMode { // if it is not in select mode
            if(productMode){ // if it is in product mode
                selectedProduct = products[indexPath.row] // selects the product
                performSegue(withIdentifier: "toEditProduct", sender: self) // perfoms the edit product segue
            }else{
                selectedProvider = providers[indexPath.row] // selects the provider
                performSegue(withIdentifier: "toProviderProducts", sender: self) // perfoms the providers product segue
            }
        }
    }
    
    // MARK: - Aux functions
    func getProviderByName(searchProvider:String) -> Provider?{
        for provider in providers{ // iterates the providers
            if provider.name == searchProvider{ // if the provider name matches with the searched one
                return provider // returns the provider object
            }
        }
        return nil // returns nothing
    }
    // MARK: - Load functions
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
    //loads providers from core data
    func loadProviders(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Provider> = Provider.fetchRequest() // get the request object
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort the request by name
        if (predicate != nil) { // in case there is a predicate
            request.predicate = predicate // set it to the request
        }
        do {
            providers = try context.fetch(request) // fetch into the context and asign it to the providers variable
        } catch {
            print("Error loading products \(error.localizedDescription)") // in case of error print the error
        }
        tableView.reloadData() // reloads the table data
    }
    //MARK: - deleting functions
    func deleteProduct(product: Product){
        context.delete(product) // deletes the product
        do {
            try context.save() // saves the context
        } catch {
            print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
        }
    }
    func deleteProvider(provider: Provider){
        context.delete(provider) // delete the provider
        do {
            try context.save() // saves the context
        } catch {
            print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
        }
    }
    //MARK: - segue functions
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductVC  { // if the destination is the product view controller
            destination.delegate = self// Get the new view controller using segue.destination. and validates if it is Product view
            if segue.identifier == "toEditProduct" { // if the segue is edit product
                destination.selectedProduct = selectedProduct  // Pass the selected product to the new view controller.
            }
        }
        if let destination = segue.destination as? ProviderProductsTVC  { // if the destination is the provider products table view controller
            destination.selectedProvider = selectedProvider // set the selected provider
        }
    }
    
    @IBAction func unwindToProductVC(_ unwindSegue: UIStoryboardSegue) { // when the modal product view is dismissed
        loadProviders()// loads products from core data
        loadProducts()// loads providers from core data
    }
    
    //MARK: - search bar functiion
    func showSearchBar() {
        searchController.searchBar.delegate = self // sets the delegate
        searchController.obscuresBackgroundDuringPresentation = false // sets false the obscure bg during presentation
        if productMode {
            searchController.searchBar.placeholder = "Search Product" // sets the search bar placeholder
        }else{
            searchController.searchBar.placeholder = "Search Provider" // sets the search bar placeholder
        }
        navigationItem.searchController = searchController // sets the search bar controller
        definesPresentationContext = true // sets the presentation context
        searchController.searchBar.searchTextField.textColor = .lightGray // sets the search bar text color
    }
}

//MARK: - search bar delegate methods
extension ProductTVC: UISearchBarDelegate {
    // when the search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 { // if the search bar is empty
            loadProducts() // load all the products
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            // add predicate, if the name and the description contains the search bar text
            if productMode{ // if product mode
                // search by product name or description if contains part of the search bar text
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!, "p_description", searchBar.text!] )
                loadProducts(predicate: predicate)  // loads products from core data
            }else{
                // search by provider name if contains part of the search bar text
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!] )
                loadProviders(predicate: predicate)  // loads providers from core data
            }
        }
    }
    // when the cancel button is pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "" // erase the search bar content
        if productMode{ // if product mode
            loadProducts() // load the products from core data
        }else{
            loadProviders()   // loads providers from core data
        }
    }
    
}
