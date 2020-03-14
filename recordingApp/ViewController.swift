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
    @IBOutlet weak var folderSelectorView : UIView!
    @IBOutlet weak var arrowButtonImage: UIImage!
    
    @IBAction func selectorByTwo(_ sender1:UIView,_ sender2: UIImage) {
        if sender1.tag == 1 || sender2.{
            
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
        let lists:[Int] = listMaking(SharedVariable.Shared.valueLast)
        while true {
                if lists.firstIndex(of: i) == nil {
                    break
                }else{
                        i = i+1
                }
        
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
        let key = ref.child("FileNames").childByAutoId().key
        
        
        if let year = components.year, let month = components.month, let day = components.day, let weekday = components.weekday, let dayOfWeek = list[weekday], let playTime = playTime, let key = key
        {
            self.ref.child("FileNames/\(key)").updateChildValues(["날짜":"\(year).\(month).\(day)","요일": dayOfWeek,"번호":"\(yes)","재생시간":"\(playTime)","파일이름":"recordFile\(yes)","시간":"\(time)"
            ], withCompletionBlock: { (Error:Error?, DatabaseReference:DatabaseReference) in
                print(Error)
            }) // if let 에서 nil 값을 넣으면  error 도 안뜨고 안넣어짐 if let 을 안 들어오는 듯
            
            
            
            SharedVariable.Shared.valueLast[key] = ["날짜":"\(year).\(month).\(day)","요일": dayOfWeek,"번호":"\(yes)","재생시간":"\(playTime)","파일이름":"recordFile\(yes)","시간":"\(time)"]
            
        
            
            
            
        
        
        
        
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
    func loadFromFireBase(completionHandler:@escaping () -> ()){
        
        let database = Database.database()
        self.ref = database.reference()
        self.ref.child("FileNames").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let value = snapshot.value as? Dictionary<String,Dictionary<String,String>> {
                
                SharedVariable.Shared.valueLast = value
                completionHandler()
                
                
                
            }
        }
        ) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidLoad() {
        
        
        loadFromFireBase( ){
            
            
            super.viewDidLoad()
            
            self.folderSelectorView.layer.cornerRadius = 7
            self.folderSelectorView.layer.borderWidth = 1
            
    
        }
        
        
        
    
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        // Do any additional setup after loading the view.
        
    }


}

