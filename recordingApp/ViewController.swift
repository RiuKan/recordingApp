//
//  ViewController.swift
//  recordingApp
//
//  Created by 류강 on 21/09/2019.
//  Copyright © 2019 류강. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, AVAudioRecorderDelegate,UINavigationControllerDelegate,UITabBarControllerDelegate {
    
    
    
    var backgroundView : UIView!
    var nowFolder: String = "기본폴더"
    var Folders: Dictionary<String,Int>! {didSet{
        tableview.reloadData()
        }}
    var tableview: UITableView!
    var progressTimer : Timer! // 타이머
    var ref:DatabaseReference! //실시간데이터 레퍼
    var storageRef: StorageReference! //스토리지 레퍼
    var audioRecorder: AVAudioRecorder! // 오디오 레코더 인스턴스
    var audioFile : URL! // 주소
    let list: [Int:String] = [1:"일요일",2:"월요일",3:"화요일",4:"수요일",5:"목요일",6:"금요일",7:"토요일"]
    let documentDirectory = FileManager.default.temporaryDirectory
    var yes: Int = 0
    var playTime: String!
    let listMaking = { (list: Dictionary<String,Dictionary<String,String>>) -> [Int] in
        var midlist: [Int] = []
        for (key,value) in list {
            if let value = value["번호"] {
            let number: Int? = Int(value) // 왜 ?빼면 coercion문제 생기는거지?
            if let number = number {
           midlist.append(number)
            }
            }
        }
        return midlist
    
    }
   
    
    
    
    
    let timeRecordSelector:Selector = #selector(ViewController.updateRecordTime)
    //  update record time = 녹음 인스턴스 현재 타임 -> 텍스트
    
    
    
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var recordingTime: UILabel!
    @IBOutlet weak var folderSelectorView : UIButton!

    
    @IBAction func selectorByTwo(_ sender1:UIButton) {
        if sender1.tag == 1 {
            if self.view.subviews.contains(tableview) == false {
            self.view.addSubview(self.tableview)
                UIView.animate(withDuration: 0.2, animations: {()->Void in self.tableview.frame.size.height = 100})
                
                
                
                let touchGestureRecg = UITapGestureRecognizer(target: self, action: #selector(outsideClick(sender: )))
                backgroundView = UIView.init(frame: self.view.window!.frame)
               backgroundView.layer.zPosition = 0.5
                backgroundView.addGestureRecognizer(touchGestureRecg)
                self.view.addSubview(backgroundView)
                self.view.bringSubviewToFront(tableview)
                
            } else {
               folderTableDelete()
                }
                tableview.reloadData()
                
            }
        }
        
    
    func folderTableDelete () {
        self.tableview.frame.size.height = 0
        self.tableview.removeFromSuperview()
        if tableview.isEditing == true {
            tableview.setEditing(false, animated: false)
    }
}
    
    @objc func outsideClick (sender: UITapGestureRecognizer) {
        if self.view.subviews.contains(tableview) {
        folderTableDelete()
            backgroundView.removeFromSuperview()
            
        }
    }
    
// selectRecordAudiofile() 로 불러온 주소에
    // 레코딩 장전
    func prepareRecording() {
        let recordSettings = [
            AVFormatIDKey : NSNumber(value : kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0] as [String : Any]
        
        do {
            // selectAudioFile 함수에서 저장한 audioFile을 url로 하는 audioRecorder 인스턴스를 생성
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSettings)
        } catch let error as NSError {
            print("error-initRecord:\(error)")
        }
        audioRecorder.delegate = self
        //박자관련
        audioRecorder.isMeteringEnabled = true
        
        audioRecorder.prepareToRecord()
        
        
        
        let session = AVAudioSession.sharedInstance()
        //  밑에 코드는 뭐지 ?
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
        } catch let error as NSError {
            print("error-setcategory : \(error)")
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("error-setActive : \(error)")
        }
        
        
        
        
    }
    // 녹음, 녹음 중지 -> 업로드 까지
    @IBAction func recordingStart (_ sender:UIButton) {
        if sender.titleLabel!.text == "🔴" {
            recordButton.setTitle("⬛️", for: UIControl.State())
            progressTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: timeRecordSelector, userInfo: nil, repeats: true)
            audioRecorder.record()
        } else if sender.titleLabel!.text == "⬛️" {
            
            progressTimer.invalidate()
            playTime = SharedVariable.Shared.convertNSTimeInterval2String(audioRecorder.currentTime)
            audioRecorder.stop()
            recordButton.setTitle("🔴", for : UIControl.State())
            
            uploadProcess()
            
        }
    }
    
   // 알고리즘 적용 예정
    func findVacancy() -> Int{
        
        var i = 0
        if SharedVariable.Shared.valueLast.count != 0 {
        var lists = [Int]()
        for folder in SharedVariable.Shared.folderCount.keys {
            let list:[Int] = listMaking(SharedVariable.Shared.valueLast[folder]!)
            lists.append(contentsOf: list)
        }
        while true {
                if lists.firstIndex(of: i) == nil {
                    break
                }else{
                        i = i+1
                }
        
        }
            return i
        }
        return i
    }
        
    
    
    func uploadProcess () {
        // File located on disk
        yes = findVacancy()
        
        let date = Date()
        let datefommater = DateFormatter()
        datefommater.locale = Locale(identifier: "ko_KR")
        datefommater.timeZone = TimeZone.autoupdatingCurrent // 왜 KST 는 작동을 안하지?
        datefommater.timeStyle = .medium
        datefommater.dateStyle = .none
        let time = datefommater.string(from: date)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .year,.month,.day], from: date)
        
        
        let storage = Storage.storage()
          storageRef = storage.reference()
        let key = ref.child("FileNames").child("\(nowFolder)").childByAutoId().key
        
        
        if let year = components.year, let month = components.month, let day = components.day, let weekday = components.weekday, let dayOfWeek = list[weekday], let playTime = playTime, let key = key
        {
            self.ref.child("FileNames/\(self.nowFolder)/\(key)").updateChildValues(["날짜":"\(year).\(month).\(day)","요일": dayOfWeek,"번호":"\(yes)","재생시간":"\(playTime)","파일이름":"recordFile\(yes)","시간":"\(time)"
            ], withCompletionBlock: { (Error:Error?, DatabaseReference:DatabaseReference) in
                print(Error)
            }) // if let 에서 nil 값을 넣으면  error 도 안뜨고 안넣어짐 if let 을 안 들어오는 듯
            
            
            
            SharedVariable.Shared.valueLast[nowFolder]?.updateValue(["날짜":"\(year).\(month).\(day)","요일": dayOfWeek,"번호":"\(yes)","재생시간":"\(playTime)","파일이름":"recordFile\(yes)","시간":"\(time)"], forKey: key)
                
            if SharedVariable.Shared.nameRecieve.keys.contains(nowFolder) == true {
                var merged:Array<String>? = SharedVariable.Shared.nameRecieve[nowFolder]
                merged?.insert(key, at: 0)
                guard let merged1 = merged else{return}
                SharedVariable.Shared.nameRecieve.updateValue(merged1, forKey: nowFolder)
            } else {
                SharedVariable.Shared.nameRecieve.updateValue([key], forKey: nowFolder)
            }
            
            
        
            
            
            
        
        
        
        
        // Create a reference to the file you want to upload
             let riversRef = storageRef.child("Recordings/이전/\(key).m4a")
        
        // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putFile(from: documentDirectory.appendingPathComponent("recordFile.m4a"), metadata: nil){ (metadata, error) in
            guard let metadata = metadata else {
                print("error occured")
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
        uploadTask.observe(.progress) {snapshot in
            if let part = snapshot.progress?.completedUnitCount, let total = snapshot.progress?.totalUnitCount { SharedVariable.Shared.showToast("\(part)/\(total)", self.view)
        }
        }
        }
    }
    
    
    @objc func updateRecordTime () {
        
        recordingTime.text = SharedVariable.Shared.convertNSTimeInterval2String(audioRecorder.currentTime)
        
    }
    
    func selectRecordAudiofile () -> Void {
            audioFile = documentDirectory.appendingPathComponent("recordFile.m4a")

    }
    
    
  
    
    
    func initPlay () {
        
        selectRecordAudiofile()
        prepareRecording()
        recordButton.isEnabled = true
    }
    func loadFromFireBase(){
        
        let database = Database.database()
        self.ref = database.reference()
        self.ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            
            
            let value1 = snapshot.childSnapshot(forPath: "FileNames").value as? Dictionary<String,Dictionary<String,Dictionary<String,String>>>
            let valueFolders = snapshot.childSnapshot(forPath:"폴더순서").value as? Array<String>
            
            guard let value11 = value1 else { return print("error") }
            guard let folderOrdering = valueFolders else{ return }
            
            
            SharedVariable.Shared.valueLast = value11
            
            
            
            var temp: Dictionary<String,Int> = [:]
                for folder in SharedVariable.Shared.valueLast.keys {
                    let list:Int = SharedVariable.Shared.valueLast[folder]!.count
                    temp.updateValue(list, forKey: folder)
                 }
            SharedVariable.Shared.folderCount = temp
            
            SharedVariable.Shared.sortedArray = folderOrdering
            self.Folders = SharedVariable.Shared.folderCount
            
            
        }
        ) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidLoad() {
        
        
            loadFromFireBase()
            initPlay()
        self.folderSelectorView.layer.borderColor = UIColor.black.cgColor
        self.folderSelectorView.layer.cornerRadius = 7
            self.folderSelectorView.layer.borderWidth = 1
            let folderSelectorViewOrigin = self.folderSelectorView.frame.origin
            let folderSelectorViewSize = self.folderSelectorView.frame.size
            self.tableview = UITableView.init(frame: CGRect.init(x: folderSelectorViewOrigin.x, y: folderSelectorViewOrigin.y + folderSelectorViewSize.height, width: folderSelectorViewSize.width, height: 0), style: .plain)
        self.tableview.layer.borderWidth = 1
        self.tableview.layer.cornerRadius = 7
        self.tableview.layer.borderColor = UIColor.black.cgColor
        self.tableview.backgroundColor = UIColor.gray
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.tableview.cellLayoutMarginsFollowReadableWidth = false
            self.tableview.separatorInset.left = 0
        
            self.tableview.delegate = self
            self.tableview.dataSource = self
        self.tableview.allowsSelectionDuringEditing = true
        self.folderSelectorView.setTitle(nowFolder, for: .normal)
        self.tableview.layer.zPosition = 999
        self.folderSelectorView.layer.zPosition = 999
        
            super.viewDidLoad()
            
            
        
        
        
        
    
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        // Do any additional setup after loading the view.
        
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if SharedVariable.Shared.folderCount.count == 0{
                return 1
            } else {
                
                    return SharedVariable.Shared.folderCount.count + 1
                
            }
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            tableview.register(UITableViewCell.self, forCellReuseIdentifier: "default")
            tableview.register(UITableViewCell.self,forCellReuseIdentifier: "edit")
            if SharedVariable.Shared.folderCount.count != 0 {
                
                if  indexPath.row == SharedVariable.Shared.folderCount.count, tableview.isEditing == false {
                    let cell = tableview.dequeueReusableCell(withIdentifier: "default",for:indexPath)
                    cell.textLabel!.text = "폴더 편집"
                    cell.textLabel!.textColor = UIColor.lightGray
                    return cell
            } else if tableview.isEditing == true ,indexPath.row == SharedVariable.Shared.folderCount.count  {
                let cell = tableview.dequeueReusableCell(withIdentifier: "default",for:indexPath)
            return cell
                
            } else {
            let cell = tableview.dequeueReusableCell(withIdentifier: "edit",for:indexPath)
                    
            cell.textLabel!.text = SharedVariable.Shared.sortedArray[indexPath.row]
                    return cell
            }
            
            
            } else {
                let cell = tableview.dequeueReusableCell(withIdentifier: "default",for:indexPath)
                return cell
            }
            
        }
    func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        if indexPath.row == SharedVariable.Shared.folderCount.count,tableview.isEditing == false {
            let cell = self.tableview.cellForRow(at: indexPath)
            cell?.textLabel!.text = "폴더 추가"
            cell?.textLabel!.textColor = UIColor.lightGray
            self.tableview.setEditing(true, animated: true)
           
            
            
        } else if indexPath.row == SharedVariable.Shared.folderCount.count, tableview.isEditing == true  {
                        let alert = UIAlertController.init(title: "폴더추가", message: "추가할 폴더의 이름을 적으시오.", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "취소", style: .cancel) {(UIAlertAction) in self.backgroundView.removeFromSuperview()}
            let confirmAction = UIAlertAction(title: "생성", style: .default) { (UIAlertAction) in
                
                guard let text = alert.textFields?[0].text else {return}
                
                let database = Database.database()
                self.ref = database.reference()
                
                SharedVariable.Shared.folderCount.updateValue(0, forKey: text)
                SharedVariable.Shared.sortedArray.append(text)
                var i = 0
                var z = Dictionary<Int,String>()
                for key in SharedVariable.Shared.sortedArray {
                    z.updateValue(key, forKey: i)
                    i = i + 1
                }
                self.ref.child("폴더순서").setValue(z)
                self.tableview.setEditing(false, animated: true)
                let indexpath1: IndexPath = IndexPath.init(row: SharedVariable.Shared.folderCount.count-1, section: 0)
                
                self.tableview.insertRows(at: [indexpath1], with: .right)
                
                
                
            }
            alert.addTextField { (UITextField) in
                
            }
            alert.addAction(cancleAction)
            alert.addAction(confirmAction)
            present(alert,animated: true)
        }else if tableview.isEditing == false {
            let cell = tableview.cellForRow(at: indexPath)
            
            guard let folderName = cell?.textLabel?.text else{return}
            nowFolder = folderName
            folderSelectorView.setTitle(folderName, for: .normal)
            backgroundView.removeFromSuperview()
            self.tableview.removeFromSuperview()
        }

        }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < SharedVariable.Shared.folderCount.count {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
         
        return .delete
       
    }
}

            // 커스텀 ui로 하려고함.
//            let viewsize = self.view.frame.size
//            let addingFolderView = UIView.init(frame: CGRect(x: viewsize.width/2-3*viewsize.width/8, y: viewsize.height/2-viewsize.height/10, width: 3*viewsize.width/4, height: viewsize.height/5))
//            addingFolderView.backgroundColor = UIColor.white
//            addingFolderView.layer.borderColor = UIColor.gray.cgColor
//            addingFolderView.layer.borderWidth = 1
//            let textField = UITextField.init(frame: CGRect(x: , y: , width: , height: ))
//            textField.backgroundColor = UIColor.white
//            textField.layer.borderColor = UIColor.black.cgColor
//            textField.layer.borderWidth = 0.5
//
//            self.view.addSubview(addingFolderView)
//            addingFolderView.addSubview(textField)
            
