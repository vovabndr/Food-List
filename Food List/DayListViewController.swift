//
//  DayListViewController.swift
//  Food List
//
//  Created by Владимир Бондарь on 6/9/18.
//  Copyright © 2018 vbbv. All rights reserved.
//

import UIKit

class DayListViewController: UIViewController {

    @IBOutlet weak var dayListTableView: UITableView!
    var foodList = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        dayListTableView.delegate = self
        dayListTableView.dataSource = self
    }
}

extension DayListViewController : UITableViewDelegate, UITableViewDataSource {
     func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodList[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayListCell", for: indexPath)
        cell.textLabel?.text =  foodList[indexPath.section][indexPath.row]
        return cell
    }
}
