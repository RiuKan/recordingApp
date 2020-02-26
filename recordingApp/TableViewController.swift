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
protocol SenddataDelegate: class {
    func sendData(data1:Int,data2:Dictionary<String,Dictionary<String,String>>,data3:UITableView,data4:Array<String>)
}
class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,sendData,Send{
    weak var delegate: SenddataDelegate?
    var value = Dictionary<String,Dictionary<String,String>>() {didSet{
        tableview.reloadData()
        }}
    var ref:DatabaseReference!
    var selected : IndexPath!
    var clickNumber : Int = 0
    var cell : WaitTableViewCell!
    var pastCell : WaitTableViewCell!
    var status: [String:String] = ["cell":"wait","pastCell":"wait"]
    
    let cellIdentifier = "cell"
    var nameReciever: Array<String>!
    var refreshcontrol = UIRefreshControl()
    var cellKey: String!
    
    let documentDirectory = FileManager.default.temporaryDirectory
    
    @IBOutlet var tableview: UITableView!
    
    
   
            // optioal any 로 오게 되는데, 이것을 깨서
            // 넣어 줘야 한다.
            
    func send(data1: Dictionary<String, Dictionary<String, String>>) {
        value = data1
    }
            // ...
    func senddata(_ data1: Dictionary<String, Dictionary<String, String>>) {
        value = data1
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
//    func visibleChange(_ target: String,_ cell: WaitTableViewCell,_ letter : String)
//    {
//        status[letter] = target
//        if target == "wait"
//        {
//
//            cell.fileName?.isHidden = true
//            cell.fileDate?.isHidden = true
//            cell.playButton?.isHidden = true
//            cell.pauseButton?.isHidden = true
//            cell.currentTime?.isHidden = true
//            cell.endTime?.isHidden = true
//            cell.stopButton?.isHidden = true
//            cell.progressView?.isHidden = true
//
//            cell.fileNameWait?.isHidden = false
//            cell.fileDateWait?.isHidden = false
//            cell.filePlayTimeWait?.isHidden = false
//
//
//
//
//
//        }
//        else if target == "select"
//        {
//            cell.fileName?.isHidden = false
//            cell.fileDate?.isHidden = false
//            cell.playButton?.isHidden = false
//            cell.pauseButton?.isHidden = false
//            cell.currentTime?.isHidden = false
//            cell.endTime?.isHidden = false
//            cell.stopButton?.isHidden = false
//            cell.progressView?.isHidden = false
//
//            cell.fileNameWait?.isHidden = true
//            cell.fileDateWait?.isHidden = true
//            cell.filePlayTimeWait?.isHidden = true
//
//        }
//    }
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
        let cell =  tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WaitTableViewCell
//        visibleChange("select", cell,"cell")
        nameReciever = Array(value.keys)
        let name = nameReciever[indexPath.row]
        cell.fileName?.text = value[name]!["파일이름"]
        cell.fileDate?.text = value[name]!["날짜"]
        cell.hideKey?.text = name
        cell.endTime?.text = value[name]!["재생시간"]
        cell.delegate = self
        // 특정 cell만 바꾼 cell 을 내놔야 하는데
        return cell
    }else{
        cell = tableview.dequeueReusableCell(withIdentifier: "sample", for: indexPath) as! WaitTableViewCell
        
//        status["cell"] = "select"
        nameReciever = Array(value.keys)
        let name = nameReciever[indexPath.row]
        cell.fileNameWait?.text = value[name]!["파일이름"]
        cell.fileDateWait?.text = value[name]!["날짜"]
        cell.filePlayTimeWait?.text = value[name]!["재생시간"]
        
        cell.delegate = self
        return cell
        }
        
        
    }
    func equalStopButton
        (cell:WaitTableViewCell){
        cell.buttonState(true, pause: false, stop: false)
        cell.audioPlayer.stop()
        
        cell.progressTimer.invalidate()
        
        cell.currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(0)
        cell.progressView.progress = 0
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        
    {   SharedVariable.Shared.row = indexPath.row
        SharedVariable.Shared.valueLast = self.value
        SharedVariable.Shared.nameRecieve = nameReciever
        SharedVariable.Shared.tableview = tableview
        
        tableview.deselectRow(at: indexPath, animated: false)
        if clickNumber == 0
        {
            
            selected = indexPath
           clickNumber = 1
           cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
            
           
           SharedVariable.Shared.nameOfFile = cell.fileNameWait?.text
            
            tableView.reloadData()
        }
        else
        {
            if  indexPath.row != selected.row {
                
                
                pastCell = tableView.cellForRow(at: selected) as!
                WaitTableViewCell
                
                cell = tableView.cellForRow(at: indexPath) as! WaitTableViewCell
                
                SharedVariable.Shared.nameOfFile = cell.fileNameWait?.text
                
                tableView.reloadData()
                if pastCell.audioPlayer != nil {
                equalStopButton(cell: pastCell) // *무조건 stop 인데 실행중 조건 걸고 하면 더 효율적일듯
                }
                selected = indexPath
            }
//            if  status["cell"] == "select"
//                    {
//                        let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
//
//                        visibleChange("select", cell, "cell")
//                        SharedVariable.Shared.nameOfFile = cell.fileName?.text
//                        let pastCell = tableview.cellForRow(at: selected) as! WaitTableViewCell?
////                        if pastCell != nil, let pastCell = pastCell
////                        {
////                            visibleChange("wait", pastCell, "pastCell")
////
////                        }
//                        if indexPath.row == selected.row {
//                            clickNumber = 0
//                        }
//                        selected = indexPath
//            }
//            } else
//            {
//                let cell = tableview.cellForRow(at: indexPath) as! WaitTableViewCell
//
//                visibleChange("wait", cell, "cell")
//
//            }  다시 클릭시 동일한 것이 꺼지도록 하는거
            
        }
    }

    @objc func refresh(){
        tableview.reloadData()
        refreshcontrol.endRefreshing()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let view = self.tabBarController?.viewControllers![0] as! ViewController
        
        view.delegate = self
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.refreshControl = refreshcontrol
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
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
