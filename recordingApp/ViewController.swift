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

class ViewController: UIViewController, AVAudioRecorderDelegate,UINavigationControllerDelegate {
    var progressTimer : Timer! // 타이머
    var ref:DatabaseReference! //실시간데이터 레퍼
    var storageRef: StorageReference! //스토리지 레퍼
    var audioRecorder: AVAudioRecorder! // 오디오 레코더 인스턴스
    var audioFile : URL! // 주소
    var NameData: [String:String] = [:] // 데이터
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var valueList:[String:Int] = [:]
    
    
    
    
    
    let timeRecordSelector:Selector = #selector(ViewController.updateRecordTime)
    //  update record time = 녹음 인스턴스 현재 타임 -> 텍스트
    
    
    
    
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var recordingTime: UILabel!
    
    
    
 
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
            audioRecorder.stop()
            recordButton.setTitle("🔴", for : UIControl.State())
            uploadProcess()
            
        }
    }
    
        
    func findVacancy() -> Int{
        ref.child("FileNames").observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value {
                self.valueList = value as! [String : Int]
                
            }
            
            
            
        }
        ){(error) in print(error.localizedDescription) }
        
        var lists:[Int] = Array(self.valueList.values)
        var i = 0
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
        let yes = findVacancy()
        let storage = Storage.storage()
          storageRef = storage.reference()
        ref.child("FileNames").updateChildValues(["recordFile\(yes)":yes])
        
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("Recordings/recordFile\(yes).m4a")
        
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
    
    
    @objc func updateRecordTime () {
        
        recordingTime.text = SharedVariable.Shared.convertNSTimeInterval2String(audioRecorder.currentTime)
        
    }
    
    func selectRecordAudiofile () -> Void {
        
        let database = Database.database()
        ref = database.reference()
        ref.child("FileNames").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
            audioFile = documentDirectory.appendingPathComponent("recordFile.m4a")
    
    }
    
    
    
    
    
    
    
    
    
        
    
    
    
    
    
    
    func initPlay () {
        
        selectRecordAudiofile()
        prepareRecording()
        recordButton.isEnabled = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
                
            }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        initPlay()
        
        // Do any additional setup after loading the view.
        
    }


}

