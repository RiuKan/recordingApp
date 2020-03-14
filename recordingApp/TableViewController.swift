//
//  TableViewController.swift
//  recordingApp
//
//  Created by 류강 on 05/10/2019.
//  Copyright © 2019 류강. All rights reserved.
//
// 중요한 계획 : 둘 모두 동시에 공유해야하는 공통의 변수는 prepare 라던지 protocol로 주고 받는 것 보단, Singleton 을 이용하는게 나음 . 프로토콜 연습용으로 구현 한거라, 바꿀 필요는 있음 .
import FirebaseDatabase
import FirebaseStorage
import UIKit


class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
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
    var onOff = 0
    let documentDirectory = FileManager.default.temporaryDirectory
    
    var windowSize : CGSize!
    var tableviewFooter : UIView!
    var button : UIButton!
    
    @IBOutlet var editButton: UIButton!
    @IBOutlet var tableview: UITableView!
    @IBOutlet var menuButton: UIButton!
    func deleteTmps (_ completionhandler: () -> () ){
        let temporary = FileManager.default.temporaryDirectory
        do{ let files = try FileManager.default.contentsOfDirectory(atPath: temporary.path)
            for files in files {
                try FileManager.default.removeItem(at: temporary.appendingPathComponent(files))
            } } catch {
                print("remove error")
        }
        
        completionhandler()
    }
    @IBAction func editButtonClicked (_ sender: UIButton)
    {
        switch onOff  {
        case 0 :
            button.isEnabled = false
            editButton.setTitle("완료", for: .normal)
            onOff = 1
            tableview.reloadData()
            tableviewFooter.backgroundColor = UIColor.groupTableViewBackground
            
             tableviewFooter.alpha = 1
            self.view.addSubview(tableviewFooter)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.tableviewFooter.frame = CGRect(x: 0, y: self.windowSize.height - 2*self.windowSize.height/12, width: self.windowSize.width, height: self.windowSize.height/12)
            }, completion: nil)
            tableview.setEditing(true, animated: true)
            
            
            
            
            
        case 1 :
            onOff = 0
            editButton.setTitle("편집", for: .normal)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
               self.tableviewFooter.frame = CGRect(x: 0, y: self.windowSize.height - self.windowSize.height/12, width: self.windowSize.width, height: self.windowSize.height/12)
            }, completion: nil)
            
            tableview.setEditing(false, animated: true)
            tableview.reloadData()
            
        default:
            break
        }
    }
    
        
    
    @IBAction func menuButtonClicked (_ sender: UIButton)
    {   let menuSlideUp = UIAlertController(title: "메뉴",message:  nil , preferredStyle: .actionSheet)
        let action = UIAlertAction.init(title: "임시파일 삭제", style: .destructive, handler: tmpFileDeleteAction(action:) )
        let cancle = UIAlertAction.init(title: "취소", style: .cancel, handler: nil)
        menuSlideUp.addAction(cancle)
        menuSlideUp.addAction(action)
        
        
        present(menuSlideUp, animated: true)
        
        
    }
    func tmpFileDeleteAction(action: UIAlertAction) {
        let actionView = UIAlertController(title: "임시파일 삭제", message: "첫 재생 시 생성된 임시파일을 삭제 합니다. 임시 파일은 다시 재생할 때 빠른 재생과 저장소의 수명을 위해 사용됩니다.(주기적으로 지워지지만, 필요시 지워주셔도 무방합니다.)", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction.init(title: "취소", style: .destructive, handler: nil)
        let actionTwo = UIAlertAction(title: "삭제", style: .default) { (UIAlertAction) in
            self.deleteTmps {
                
                SharedVariable.Shared.showToast("delete complete", (UIApplication.shared.keyWindow?.rootViewController!.view)!)
            }
        }
        
        actionView.addAction(action)
        actionView.addAction(actionTwo)
        
        
        present(actionView,animated: true)
    }
   
            // optioal any 로 오게 되는데, 이것을 깨서
            // 넣어 줘야 한다.
            
    
            // ...
//    func senddata(_ data1: String, _ data2: String) {
//
//        value[data2]!["파일이름"] = data1
//        value[data2]!["번호"] = nil
//    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //        if let counts = self.value?.count {
        //        return counts
        //        }
        return SharedVariable.Shared.valueLast.count
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
    
    func datePresent(date: Date,name: String) -> String{
        let dateformatterD = DateFormatter()
        
        dateformatterD.dateFormat = "yyyy.MM.dd" // mm 이 아니라 MM 으로 구분 해주지 않으면 이상한 날짜로 들어감
        dateformatterD.timeZone = TimeZone(abbreviation: "GMT")
//        let dateformatterT = DateFormatter()
//        dateformatterT.locale = Locale(identifier: "ko_KR")

//        dateformatterT.timeStyle = .medium
        // 날짜 설정 중요 : 타임존 GMT 로 해주어야, 국내 시간 변환시 맞음 .
        // ko locale 설정시 하루 차이 나버림 .
        // 기본 date 는 default 는 15시간 차이(설정 안 했을때)
        let nowdate = dateformatterD.string(from: date)
        if let d1 = SharedVariable.Shared.valueLast[name]!["날짜"] {
           
            let d1date: Date = dateformatterD.date(from: d1 )!
            
            let nowdate = dateformatterD.date(from: nowdate)!
            
            
            
            if  d1date == nowdate {
                
                return SharedVariable.Shared.valueLast[name]!["시간"]!
                
            } else if (nowdate-604800 <= d1date &&  d1date < nowdate-86400) || (d1date >= nowdate+86400 && d1date < nowdate+604800){// 어제는 따로 , 일주일 전까지
                
                return SharedVariable.Shared.valueLast[name]!["요일"]!
                
            } else if nowdate-86400 <= d1date, d1date < nowdate+86400{
                
                return "어제"
            } else {
                
                return SharedVariable.Shared.valueLast[name]!["날짜"]!
            }
        } else {
            return "error"
        } //  연산 한꺼번에 b<a<c쓰면 오류, b<a,a<c 로 따로.
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {   let date = Date()
        let name = SharedVariable.Shared.nameRecieve[indexPath.row]
        if indexPath.row == selected?.row, onOff == 0{
        let cell =  tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WaitTableViewCell
//        visibleChange("select", cell,"cell")
        
        
        cell.fileName?.text = SharedVariable.Shared.valueLast[name]!["파일이름"]
        cell.fileDate?.text = datePresent(date: date, name: name)
        cell.hideKey?.text = name
        cell.endTime?.text = SharedVariable.Shared.valueLast[name]!["재생시간"]
        
        // 특정 cell만 바꾼 cell 을 내놔야 하는데
        return cell
    }else{
        cell = tableview.dequeueReusableCell(withIdentifier: "sample", for: indexPath) as! WaitTableViewCell
        
//        status["cell"] = "select"
        
        let name = SharedVariable.Shared.nameRecieve[indexPath.row]
        cell.fileNameWait?.text = SharedVariable.Shared.valueLast[name]!["파일이름"]
        cell.fileDateWait?.text = datePresent(date: date, name: name)
        cell.filePlayTimeWait?.text = SharedVariable.Shared.valueLast[name]!["재생시간"]
        cell.hideKey?.text = name
        
        
        return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        <#code#>
    }
    func equalStopButton
        (cell:WaitTableViewCell){
        cell.buttonState(true, pause: false, stop: false)
        
        SharedVariable.Shared.audioPlayer.stop()
        
        cell.progressTimer.invalidate()
        
        cell.currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(0)
        cell.progressView.progress = 0
        
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    {
        if onOff == 0 {
         SharedVariable.Shared.row = indexPath.row
        
        
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
                
                
               
                
                
                cell = tableView.cellForRow(at: indexPath) as! WaitTableViewCell
                
                SharedVariable.Shared.nameOfFile = cell.fileNameWait?.text
                
                
                if SharedVariable.Shared.audioPlayer != nil{
                    equalStopButton(cell: cell) // *무조건 stop 인데 실행중 조건 걸고 하면 더 효율적일듯
                }
                tableView.reloadData()
                selected = indexPath
            }
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
        if tableView.indexPathsForSelectedRows != nil {
            button.isEnabled = true            }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil{
            
            button.isEnabled = false
        }
    }

    @objc func refresh(){
        tableview.reloadData()
        refreshcontrol.endRefreshing()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
         // (교체요망) 프로토콜로 넘겨서 일관성을 통해 효율적으로 관리 필요
        SharedVariable.Shared.tableview = tableview
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.refreshControl = refreshcontrol
        
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
         tableview.allowsMultipleSelectionDuringEditing =
        true
        
        windowSize = self.view.frame.size
        
        
        tableviewFooter = UIView(frame: CGRect(x: 0, y: windowSize.height - windowSize.height/12, width: windowSize.width, height: windowSize.height/12 ))
        button = UIButton(frame: CGRect(x: 5*windowSize.width/6, y: 10, width: windowSize.width/6, height: windowSize.height/24))
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.setTitleColor(UIColor.systemGray, for: .disabled)
        tableviewFooter.addSubview(button)
        
        button.addTarget(self, action: #selector(deleteButtonAlert), for: .touchUpInside)
        
        
    }
    @objc func deleteButtonAlert() {
        let action = UIAlertController(title: "선택된 파일들을 삭제하시겠습니까?", message: "삭제된 파일들은 되돌릴 수 없습니다.", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteButton = UIAlertAction(title: "삭제", style: .default,handler: {(UIAlertAction)->() in
            self.button.isEnabled = false
            let lists = self.tableview.indexPathsForSelectedRows
        let storage = Storage.storage()
        let storageref = storage.reference()
        let database = Database.database()
        let ref = database.reference()
        if lists != nil , let lists = lists {
            
            let temporary = FileManager.default.temporaryDirectory
        for list in lists {
            
            let hideKey = SharedVariable.Shared.nameRecieve[list.row]
            do{ try FileManager.default.removeItem(at: temporary.appendingPathComponent("\(hideKey).m4a"))
                } catch {
                    print("remove error")
            }
                
                storageref.child("Recordings").child("이전").child("\(hideKey).m4a").delete(completion: {(Error) -> () in print(Error)})
                ref.child("FileNames").child(hideKey).removeValue()
                
                SharedVariable.Shared.valueLast.removeValue(forKey: hideKey)
            
            }
        }
        })
        action.addAction(cancelButton)
        action.addAction(deleteButton)
        self.present(action, animated: true)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        
        
        
        
        self.tableview.reloadData()
        clickNumber = 0
        selected = nil
        
        
        
    }
    

}

    
    

