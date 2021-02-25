//
//  OrderCoffeeViewController.swift
//  CoffeeOrderMVVM
//
//  Created by Ashish Yadav on 24/02/21.
//

import Foundation
import UIKit

class OrderCoffeeViewController: UITableViewController, AddCoffeeOrderDelegate {
    
    var orderListViewModel  = OrderListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateOrders()
    }
    
    func didSaveOnClick(order: Order, controller: UIViewController) {
        controller.dismiss(animated: true, completion: nil)
        let ordervm = OrderViewModel(order: order)
        self.orderListViewModel.orderViewModel.append(ordervm)
        self.tableView.insertRows(at: [IndexPath.init(row: self.orderListViewModel.orderViewModel.count-1, section: 0)], with: .automatic)
    }
    
    func didCloseOnSave(controller: UIViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navC = segue.destination as? UINavigationController, let addCoffeeOrderVC = navC.viewControllers.first as? AddNewOrderViewController else {
            fatalError()
        }
        addCoffeeOrderVC.delegate = self
    }
    
    func populateOrders() {
        
        Webservice().load(resource: Order.all) {[weak self] result in
            
            switch result {
            case .success(let orders):
                print(orders)
                self?.orderListViewModel.orderViewModel = orders.map(OrderViewModel.init)
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderListViewModel.orderViewModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = self.orderListViewModel.orderViewModel(at: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell",for: indexPath)
        cell.textLabel?.text = vm.type
        cell.detailTextLabel?.text = vm.size
        return cell
    }
    
}
