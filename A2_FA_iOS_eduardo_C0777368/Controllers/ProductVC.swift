//
//  ViewController.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductVC: UIViewController {
    
    var selectedProduct: Product? = nil // the selected product in case to be an edit process
    weak var delegate: ProductTVC? // product table view controller delegate
    
    @IBOutlet weak var nameTxt: UITextField! // name label IBOutlet
    @IBOutlet weak var idTxt: UITextField! // id label IBOutlet
    @IBOutlet weak var pDescriptionTxt: UITextView! // description text view IBOutlet
    @IBOutlet weak var priceTxt: UITextField! // price label IBOutlet
    @IBOutlet weak var providerTxt: UITextField! // provider label IBOutlet
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idTxt.text = "" // set the id field empty
        nameTxt.text = ""  // set the name field empty
        providerTxt.text = ""  // set the provider field empty
        priceTxt.text = ""  // set the price field empty
        pDescriptionTxt.text = ""  // set the description field empty
        pDescriptionTxt.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2) // set the descriptionfield border color
        pDescriptionTxt.layer.borderWidth = 1.0 // set the descriptionfield border width
        pDescriptionTxt.layer.cornerRadius = 5.0 // set the descriptionfield corner radius
        if selectedProduct != nil{ // if there is a selected product
            idTxt.text = selectedProduct?.id // sets the id into the label
            nameTxt.text = selectedProduct?.name // sets the name into the label
            providerTxt.text = selectedProduct?.parentProvider!.name // sets the provider into the label
            priceTxt.text = String(selectedProduct!.price)// setsand formats the price into the label
            pDescriptionTxt.text = selectedProduct?.p_description // sets the description into the text view
        }
    }
    
    @IBAction func saveBtnClick(_ sender: Any) {
        var message = ""
        if(idTxt.text?.count == 0) { // validates the emptiness of the id field
            message = "Please set an id for the product"
        }else if (nameTxt.text?.count == 0){ // validates the emptiness of the name field
            message = "Please set a name for the product"
        }else if (providerTxt.text?.count == 0){ // validates the emptiness of the provider field
            message = "Please set a provider for the product"
        }else if (priceTxt.text?.count == 0){ // validates the emptiness of the price field
            message = "Please select a name for the product"
        }
        if(message != "") { // if there is an error
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert) // set the alert object
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil) // set the OK button
            alert.addAction(okAction) // add the ok action button
            present(alert, animated: true, completion: nil) // present the alert button
        }else {
            let currProvider = selectedProduct?.parentProvider // gets the current provider if set
            if selectedProduct == nil { // if it is a new product
                selectedProduct = Product(context: delegate!.context) // create a new product object
            }
            selectedProduct?.id = idTxt.text // sets the id value from the field
            selectedProduct?.name = nameTxt.text // sets the name value from the field
            selectedProduct?.p_description = pDescriptionTxt.text // sets the description value from the field
            selectedProduct?.price = Double(priceTxt.text!)! // sets the price value from the field
            
            var editProvider = delegate?.getProviderByName(searchProvider: providerTxt.text! ) // gets the provider if exists, from the field
            if editProvider == nil { // if not found
                editProvider = Provider(context: delegate!.context) // create a new provider object
                editProvider?.name = providerTxt.text! // set the provider name
            }
            selectedProduct?.parentProvider = editProvider // set the relationship between the product and the provider
            if selectedProduct == nil { // if it is a new product
                delegate?.products.append(selectedProduct!) // append the product to the array
            }else{
                // if the provider has changed for an existing product, validate if this is the last product for this provider
                if currProvider != nil && editProvider?.name != currProvider?.name && (currProvider?.products!.count)! < 2{
                    delegate?.context.delete(currProvider!)  // delete the provider
                }
            }
            do {
                try delegate?.context.save() // saves the context
            } catch {
                print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
            }
            performSegue(withIdentifier: "dismissToProductVC", sender: self) // dismiss modal view
        }
    }

    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil) // dismiss in case of cancel
    }
}

