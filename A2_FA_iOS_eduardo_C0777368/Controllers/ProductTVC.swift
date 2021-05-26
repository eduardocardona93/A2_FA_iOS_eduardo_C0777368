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
    var providers = [Provider]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // create the context to work with core data
    
    
    var selectedProduct: Product? = nil
    var selectedProvider: Provider? = nil
    let searchController = UISearchController(searchResultsController: nil) // define the search controller
    var productMode = true
    var selectMode = false
    
    @IBOutlet weak var deleteBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProviders()
        loadProducts()
        showSearchBar() // shows and sets the search bar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadProviders()
        loadProducts()
    }
    
    @IBAction func listEditClick(_ sender: Any) {
        selectMode = !selectMode
        deleteBtn.isEnabled = !deleteBtn.isEnabled
        tableView.setEditing(selectMode, animated: true)
    }
    
    @IBAction func changeMode(_ sender: UIBarItem) {
        if productMode {
            navigationItem.title = "Providers"
            sender.image = UIImage(systemName: "list.bullet")
        }else{
            navigationItem.title = "Products"
            sender.image = UIImage(systemName: "square.stack.3d.up.fill")
        }
        productMode = !productMode
        tableView.reloadData()
    }
    // MARK: - Table view functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if productMode{
            return products.count
        }else{
            return providers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "view_cell", for: indexPath) // gets the cell element
        if productMode {
            cell.textLabel?.text = products[indexPath.row].name! // sets the title as the product name and id
            cell.detailTextLabel?.text = String((products[indexPath.row].parentProvider?.name)! )// sets the detail as the product price
        }else{
            cell.textLabel?.text = providers[indexPath.row].name! // sets the title as the product name and id
            cell.detailTextLabel?.text = String(providers[indexPath.row].products!.count )// sets the detail as the product price
        }
        
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
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if productMode {
                deleteProduct(product: products[indexPath.row])
                products.remove(at: indexPath.row)
                for (provider) in providers{
                    if provider.products?.count == 0 {
                        deleteProvider(provider: provider)
                    }
                }
            }else{
                deleteProvider(provider: providers[indexPath.row])
                providers.remove(at: indexPath.row)
            }
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            loadProviders()
            loadProducts()
        } 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectMode {
            if(productMode){
                selectedProduct = products[indexPath.row]
                performSegue(withIdentifier: "toEditProduct", sender: self)
            }else{
                selectedProvider = providers[indexPath.row]
                performSegue(withIdentifier: "toProviderProducts", sender: self)
            }
        }
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
    func getProviderByName(searchProvider:String) -> Provider?{
        for provider in providers{
            if provider.name == searchProvider{
                return provider
            }
        }
        return nil
    }
    func loadProviders(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Provider> = Provider.fetchRequest() // get the request object
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort the request by name
        if (predicate != nil) { // in case there is a predicate
            request.predicate = predicate // set it to the request
        }
        do {
            providers = try context.fetch(request) // fetch into the context and asign it to the products variable
        } catch {
            print("Error loading products \(error.localizedDescription)") // in case of error print the error
        }
        tableView.reloadData() // reloads the table data
    }
    func deleteProduct(product: Product){
        context.delete(product)
        do {
            try context.save() // saves the context
        } catch {
            print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
        }
    }
    
    func deleteProvider(provider: Provider){
        context.delete(provider)
        do {
            try context.save() // saves the context
        } catch {
            print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
        }
    }
    //MARK: - segue functions
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductVC  {
            destination.delegate = self// Get the new view controller using segue.destination. and validates if it is Product view
            if segue.identifier == "toEditProduct" {
                destination.selectedProduct = selectedProduct  // Pass the selected product to the new view controller.
            }
        }
        if let destination = segue.destination as? ProviderProductsTVC  {
            destination.selectedProvider = selectedProvider
        }
    }
    
    @IBAction func unwindToProductVC(_ unwindSegue: UIStoryboardSegue) {
        loadProviders()
        loadProducts()
        tableView.setEditing(false, animated: true)
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
    // when the text in text bar is changed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 { // if the search bar is empty
            loadProducts() // load all the products
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            // add predicate, if the name and the description contains the search bar text
            if productMode{
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!, "p_description", searchBar.text!] )
                loadProducts(predicate: predicate)  // loads products from core data
            }else{
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!] )
                loadProviders(predicate: predicate)  // loads products from core data
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        if productMode{
            loadProducts()
        }else{
            loadProviders()
        }
    }
    
}
