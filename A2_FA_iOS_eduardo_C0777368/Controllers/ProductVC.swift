//
//  ViewController.swift
//  A2_FA_iOS_eduardo_C0777368
//
//  Created by Eduardo Cardona on 2021-05-21.
//

import UIKit
import CoreData

class ProductVC: UIViewController {
    
    var selectedProduct: Product? 
    var products = [Product]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var pDescriptionTxt: UITextView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var providerLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedProduct == nil {
            let request: NSFetchRequest<Product> = Product.fetchRequest()
            request.fetchLimit = 1;
            do {
                products = try context.fetch(request)
                selectedProduct = products[0]
                
            } catch {
                print("Error loading folders \(error.localizedDescription)")
            }
        }
        idLbl.text = selectedProduct?.id
        nameLbl.text = selectedProduct?.name
        providerLbl.text = selectedProduct?.provider
        pDescriptionTxt.text = selectedProduct?.p_description
        productImg.image = UIImage(named: selectedProduct?.id ?? "")
        priceLbl.text = "$" + String(format: "%.2f", Double(selectedProduct!.price))


        
       
    }


}

