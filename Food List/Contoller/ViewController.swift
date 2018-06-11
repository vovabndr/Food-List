//
//  ViewController.swift
//  Food List
//
//  Created by Владимир Бондарь on 6/7/18.
//  Copyright © 2018 vbbv. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import GTMOAuth2

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTableView: UITableView!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    var nameArr = [[Any]]()
    var Sheet = [[[Any]]]()

    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    private let service = GTLRSheetsService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        signInButton.style = .wide
        
        nameTableView.delegate = self
        nameTableView.dataSource = self
    }
    

}

extension ViewController:  GIDSignInDelegate, GIDSignInUIDelegate{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if (error) != nil {
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            getList()
        }
    }
    
    func getList() {
        let spreadsheetId = spreadSheetID
        for day in days {
            let range = "\(day)!A1:M34"
            let query = GTLRSheetsQuery_SpreadsheetsValuesGet
                .query(withSpreadsheetId: spreadsheetId, range:range)
            service.executeQuery(query,delegate: self,didFinish: #selector(displayResultWithTicket))
        }
    }
    
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRSheets_ValueRange,
                                       error : NSError?) {
        guard error == nil else {
            return
        }
        let rows = result.values!
        if rows.isEmpty {
            return
        }
        Sheet.append(rows)
        nameArr = rows
        nameTableView.reloadData()
    }
    
    func buildList(index : Int)->[[Any]] {
        var menu = [[Any]]()
        for days in 0..<Sheet.count {
            var dayDish = [Any]()
            for people in 0..<Sheet[days].count where people == index {
                for food in 0..<Sheet[days][people].count
                    where !(Sheet[days][people][food] as! String).isEmpty &&
                        !(Sheet[days][1][food] as! String).isEmpty  {
                            dayDish.append(Sheet[days][1][food])
                }
            }
            menu.append(dayDish)
        }
        return menu
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)
        cell.textLabel?.text = nameArr[indexPath.row][0] as? String
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 0.0
        }
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier:
            "DayListViewController") as? DayListViewController
        controller?.foodList = buildList(index: indexPath.row) as! [[String]]
        navigationController!.pushViewController(controller!, animated: true)
    }
}
