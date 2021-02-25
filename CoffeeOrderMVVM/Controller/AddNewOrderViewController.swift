//
//  AddNewOrderViewController.swift
//  CoffeeOrderMVVM
//
//  Created by Ashish Yadav on 24/02/21.
//

import Foundation
import UIKit

protocol  AddCoffeeOrderDelegate {
    func didSaveOnClick(order:Order,controller:UIViewController)
    func didCloseOnSave(controller:UIViewController)
    
}

class AddNewOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var vm = AddCoffeeOrderViewModel()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    
    private var coffeeSizesSegmentedViewController : UISegmentedControl!
    
    var delegate: AddCoffeeOrderDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        //Looks for single or multiple taps.
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

           //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
           tap.cancelsTouchesInView = false

           view.addGestureRecognizer(tap)
        self.coffeeSizesSegmentedViewController = UISegmentedControl(items: self.vm.sizes)
        self.coffeeSizesSegmentedViewController.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.coffeeSizesSegmentedViewController)
        
        self.coffeeSizesSegmentedViewController.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 20).isActive = true
        self.coffeeSizesSegmentedViewController.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.types.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeTypeTableViewCell",for: indexPath)
        cell.textLabel?.text = self.vm.types[indexPath.row]
        return cell
    }
    
    @IBAction func closeButtonOnClick() {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.didCloseOnSave(controller: self)
            }
        }
    }
    
    @IBAction func saveButtonOnClick() {
        let name = nameTextfield.text
        let email = emailTextfield.text
        
        let size = coffeeSizesSegmentedViewController.titleForSegment(at: coffeeSizesSegmentedViewController.selectedSegmentIndex)
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            fatalError("Error in selecting Coffee")
        }
        
        self.vm.email = email
        self.vm.name = name
        self.vm.selectedSize  = size
        self.vm.selectedType = self.vm.types[indexPath.row]
        
        Webservice().load(resource: Order.create(vm: self.vm)) { result in
            switch result{
            case .success(let order):
                DispatchQueue.main.async {
                    if let order = order, let delegate = self.delegate {
                        delegate.didSaveOnClick(order: order, controller: self)
                    }
                }
                print(order)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}
