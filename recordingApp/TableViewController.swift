//
//  TableViewController.swift
//  recordingApp
//
//  Created by 류강 on 05/10/2019.
//  Copyright © 2019 류강. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var value:[String:Int]! = [:]
    var ref:DatabaseReference!
    var selected : IndexPath!
    var clickNumber : Int = 0
    var cell : WaitTableViewCell!
    var pastCell : WaitTableViewCell!
    var status: [String:String] = ["cell":"wait","pastCell":"wait"]
    let cellIdentifier = "cell"
    
 
    
    @IBOutlet var tableview: UITableView!
    
    
    func downloadLists () {
        let database = Database.database()
       ref = database.reference()
        ref.child("FileNames").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let values = snapshot.value {
            self.value = values as? [String:Int]
            }
            // optioal any 로 오게 되는데, 이것을 깨서
            // 넣어 줘야 한다.
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        if let counts = self.value?.count {
        //        return counts
        //        }
        return value.count
    }
    func visibleChange(_ target: String,_ cell: WaitTableViewCell,_ letter : String)
    {
        status[letter] = target
        if target == "wait"
        {
            
            cell.fileName?.isHidden = true
            cell.fileDate?.isHidden = true
            cell.playButton?.isHidden = true
            cell.pauseButton?.isHidden = true
            cell.currentTime?.isHidden = true
            cell.endTime?.isHidden = true
            cell.stopButton?.isHidden = true
            cell.progressView?.isHidden = true
            
            cell.fileNameWait?.isHidden = false
            cell.fileDateWait?.isHidden = false
            cell.filePlayTimeWait?.isHidden = false
            
            
            
            
            
        }
        else if target == "select"
        {
            cell.fileName?.isHidden = false
            cell.fileDate?.isHidden = false
            cell.playButton?.isHidden = false
            cell.pauseButton?.isHidden = false
            cell.currentTime?.isHidden = false
            cell.endTime?.isHidden = false
            cell.stopButton?.isHidden = false
            cell.progressView?.isHidden = false
            
            cell.fileNameWait?.isHidden = true
            cell.fileDateWait?.isHidden = true
            cell.filePlayTimeWait?.isHidden = true
            
        }
    }
    func initLayout()
    {
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {   if indexPath.row == selected?.row {
        let cell =  tableview.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WaitTableViewCell
        visibleChange("select", cell,"cell")
        cell.fileName?.text = Array(value.keys)[indexPath.row]
        // 특정 cell만 바꾼 cell 을 내놔야 하는데 
        return cell
    }else{
        let cell = tableview.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WaitTableViewCell
        visibleChange("wait", cell,"cell")
        status["cell"] = "select"
        cell.fileName?.text = Array(value.keys)[indexPath.row]
        
        return cell
        }
        
        
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableview.deselectRow(at: indexPath, animated: false)
        if clickNumber == 0
        {
            selected = indexPath
            clickNumber = 1
            let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
            
            visibleChange("select", cell, "cell")
            SharedVariable.Shared.nameOfFile = cell.fileName?.text
        }
        else
        {
            if  status["cell"] == "select"
                    {
                        let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
            
                        visibleChange("select", cell, "cell")
                        SharedVariable.Shared.nameOfFile = cell.fileName?.text
                        let pastCell = tableview.cellForRow(at: selected) as! WaitTableViewCell?
                            if pastCell != nil, let pastCell = pastCell
                            {
                                visibleChange("wait", pastCell, "pastCell")
                                
                            }
                        if indexPath.row == selected.row {
                            clickNumber = 0
                        }
                        selected = indexPath
                }
                else
                {
                    let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
            
                    visibleChange("wait", cell, "cell")
                    
                }
        }
    }

//        if status["cell"] == "wait"{
//        let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
//
//        visibleChange("select", cell,"cell")
//        }
        
//        else if clickNumber == 1 {
//            if selected.row != indexPath.row{
//            let pastCell = tableview.cellForRow(at: selected) as! WaitTableViewCell?
//
//            if pastCell != nil, let pastCell = pastCell
//            {
//            visibleChange("wait", pastCell,"pastCell")
//
//            }
//            }else {
//                if status["cell"] == "select" {
//                    let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
//
//                    visibleChange("wait", cell, "cell")
//
//
//            }
//            selected = indexPath
        
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        
        
        
        
        self.tableview.reloadData()
        clickNumber = 0
        selected = nil
        
        
        
    }
    
    
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    

    // MARK: - Table view data source

    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
