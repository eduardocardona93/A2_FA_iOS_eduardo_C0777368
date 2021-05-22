//
//  ViewController.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductVC: UIViewController {
    
    var selectedProduct: Product? // the selected product

    @IBOutlet weak var nameLbl: UILabel! // name label IBOutlet
    @IBOutlet weak var idLbl: UILabel! // id label IBOutlet
    @IBOutlet weak var pDescriptionTxt: UITextView! // description text view IBOutlet
    @IBOutlet weak var priceLbl: UILabel! // price label IBOutlet
    @IBOutlet weak var productImg: UIImageView! // product image view IBOutlet
    @IBOutlet weak var providerLbl: UILabel! // provider label IBOutlet
    override func viewDidLoad() {
        super.viewDidLoad()
       
        idLbl.text = selectedProduct?.id // sets the id into the label
        nameLbl.text = selectedProduct?.name // sets the name into the label
        providerLbl.text = selectedProduct?.provider // sets the provider into the label
        pDescriptionTxt.text = selectedProduct?.p_description // sets the description into the text view
        productImg.image = UIImage(named: selectedProduct?.id ?? "") // sets the image into the image view using the id
        priceLbl.text = "$" + String(format: "%.2f", Double(selectedProduct!.price)) // setsand formats the price into the label
    }

    

}

