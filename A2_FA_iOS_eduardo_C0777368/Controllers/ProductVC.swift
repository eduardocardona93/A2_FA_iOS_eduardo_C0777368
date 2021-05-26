//
//  ViewController.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductVC: UIViewController {
    
    var selectedProduct: Product? = nil// the selected product

    weak var delegate: ProductTVC?
    
    @IBOutlet weak var nameTxt: UITextField! // name label IBOutlet
    @IBOutlet weak var idTxt: UITextField! // id label IBOutlet
    @IBOutlet weak var pDescriptionTxt: UITextView! // description text view IBOutlet
    @IBOutlet weak var priceTxt: UITextField! // price label IBOutlet
    @IBOutlet weak var providerTxt: UITextField! // provider label IBOutlet
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idTxt.text = ""
        nameTxt.text = ""
        providerTxt.text = ""
        priceTxt.text = ""
        pDescriptionTxt.text = ""
        
        if selectedProduct != nil{
            idTxt.text = selectedProduct?.id // sets the id into the label
            nameTxt.text = selectedProduct?.name // sets the name into the label
            providerTxt.text = selectedProduct?.parentProvider!.name // sets the provider into the label

            priceTxt.text = String(selectedProduct!.price)// setsand formats the price into the label
            pDescriptionTxt.text = selectedProduct?.p_description // sets the description into the text view
        }
        

    }
    
    

    @IBAction func saveBtnClick(_ sender: Any) {
        var message = ""
        
        if(idTxt.text?.count == 0) {
            message = "Please set an id for the product"
        }else if (nameTxt.text?.count == 0){
            message = "Please set a name for the product"
        }else if (providerTxt.text?.count == 0){
            message = "Please set a provider for the product"
        }else if (priceTxt.text?.count == 0){
            message = "Please select a name for the product"
        }
        
        if(message != "") {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }else {
            let currProvider = selectedProduct?.parentProvider
            // new product
            if selectedProduct == nil {
                selectedProduct = Product(context: delegate!.context)
            }
            selectedProduct?.id = idTxt.text
            selectedProduct?.name = nameTxt.text
            selectedProduct?.p_description = pDescriptionTxt.text
            selectedProduct?.price = Double(priceTxt.text!)!
            
            var editProvider = delegate?.getProviderByName(searchProvider: providerTxt.text! )
            if editProvider == nil {
                editProvider = Provider(context: delegate!.context)
                editProvider?.name = providerTxt.text!
            }
            selectedProduct?.parentProvider = editProvider
            if selectedProduct == nil {
                delegate?.products.append(selectedProduct!)
            }else{
                
                if currProvider != nil && editProvider?.name != currProvider?.name && (currProvider?.products!.count)! < 2{
                   delegate?.context.delete(currProvider!)
                }
                
            }
            do {
                try delegate?.context.save() // saves the context
            } catch {
                print("Error saving the product \(error.localizedDescription)")  // in case of error print the error
            }
            performSegue(withIdentifier: "dismissToProductVC", sender: self)
            
                

            }

        }
    
    

    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

