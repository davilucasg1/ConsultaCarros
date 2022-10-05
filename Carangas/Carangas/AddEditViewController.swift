// app carangas

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    // priperties
    var car: Car!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if car != nil{
            
            tfBrand.text = car.brand
            tfName.text = car.name
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        if car == nil{
            car = Car()
        }
        car.name = tfName.text!
        car.brand = tfBrand.text!
        if tfPrice.text!.isEmpty {tfPrice.text = "0"}// testa se o valor é vazio
        car.price = Double(tfPrice.text!)! // teclado é numblepad ent pode converter em double
        car.gasType = scGasType.selectedSegmentIndex
        // iff pra definir se esta salvando ou editando 
        if car._id == nil {
            REST.save(car: car) { (success) in
                self.goBack()
            }
        }else {
            REST.update(car: car) { (success) in
                self.goBack()
            }
        }
        
    }
   
    //voltar ao inicio
    func goBack () {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}




