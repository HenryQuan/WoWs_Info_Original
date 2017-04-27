//
//  ClanInfoController.swift
//  WoWs Info
//
//  Created by Henry Quan on 24/4/17.
//  Copyright © 2017 Henry Quan. All rights reserved.
//

import UIKit

class ClanInfoController: UITableViewController {

    var clanDataString: String!
    var clanTag: String!
    var clanName: String!
    var clanMember: String!
    var clanID: String!
    var clanInfo = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup TableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clear
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Load data here
        let passedData = clanDataString.components(separatedBy: " | ")
        clanID = passedData[0]
        clanMember = passedData[1]
        clanName = passedData[2]
        clanTag = passedData[3]
        
        self.title = clanID
        
        // Get data from API
        ClanInfo(ID: clanID).getClanList { (Clan) in
            DispatchQueue.main.async {
                self.clanInfo = Clan
                print("Clan: \(Clan)")
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clanInfo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // First cell is gonna be  ClanCell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClanCell", for: indexPath) as! ClanCell
            cell.clanNameWithTag.text = "[\(clanTag!)] \(clanName!)"
            cell.clanDescription.text = clanInfo[0][ClanInfo.dataIndex.description]
            cell.leaderName.text = clanInfo[0][ClanInfo.dataIndex.leader]
            cell.memberCountLabel.text = "Member List (\(self.clanMember!))"
            cell.backgroundColor = UIColor.init(red: 112/255, green: 177/255, blue: 251/255, alpha: 1)
            return cell
        } else {
            // Member list
            let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
            cell.memberName.text = clanInfo[indexPath.row][ClanInfo.dataIndex.name]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            if UserDefaults.standard.bool(forKey: DataManagement.DataName.IsAdvancedUnlocked) == true {
                // From member list, Pro only
                performSegue(withIdentifier: "gotoAdvancedInfo", sender: indexPath.row)
            } else {
                let proOnly = UIAlertController(title: "Sorry", message: "This is for pro version only. Update to Pro version to use this feature.", preferredStyle: .alert)
                proOnly.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(proOnly, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if UserDefaults.standard.bool(forKey: DataManagement.DataName.IsAdvancedUnlocked) == true {
            // Change text to "Back"
            let backItem = UIBarButtonItem()
            backItem.title = NSLocalizedString("BACK", comment: "Back button")
            navigationItem.backBarButtonItem = backItem
            
            // Only segue for pro users
            if segue.identifier == "gotoAdvancedInfo" {
                let destination = segue.destination as! AdvancedInfoController
                let index = sender as! Int
                destination.playerInfo = [clanInfo[index][ClanInfo.dataIndex.name], clanInfo[index][ClanInfo.dataIndex.id]]
            }
        }
    }

}
