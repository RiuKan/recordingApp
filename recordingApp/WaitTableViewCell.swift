//
//  WaitTableViewCell.swift
//  recordingApp
//
//  Created by 류강 on 05/10/2019.
//  Copyright © 2019 류강. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import FirebaseStorage

class WaitTableViewCell: UITableViewCell, AVAudioPlayerDelegate, UINavigationControllerDelegate {
    
     
    var progressTimer : Timer!
    
    let maxVolume: Float = 10.0
    var ref: DatabaseReference!
    var repeater: Int = 0
    var downloadTask: StorageDownloadTask!
    
    let documentDirectory = FileManager.default.temporaryDirectory
    
    
    // 실행 ui
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var hideKey: UILabel!
    
    @IBOutlet weak var fileDate: UILabel!
    @IBOutlet weak var fileName: UITextField!
    
    @IBOutlet weak var fileNameWait: UILabel!
    @IBOutlet weak var fileDateWait: UILabel!
    @IBOutlet weak var filePlayTimeWait: UILabel!
    
    @IBAction func filenameChange (_ sender:UITextField) {
        let name  = fileName.text
        let sectionName = SharedVariable.Shared.sortedArray[SharedVariable.Shared.section]
        let id = SharedVariable.Shared.nameRecieve[sectionName]![SharedVariable.Shared.row]
        if let name = name {
           ref = Database.database().reference()
            ref.child("FileNames").child("\(sectionName)").child("\(id)").child("파일이름").setValue("\(name)")
           
            ref.child("FileNames").child("\(sectionName)").child("\(id)").child("번호").setValue(nil)
            
            SharedVariable.Shared.valueLast[sectionName]!["\(id)"]!["파일이름"] = "\(name)"
            
            SharedVariable.Shared.valueLast[sectionName]!["\(id)"]!["번호"] = nil
        }
        // 여기 valueLast.keys만 변수 따로 담아주면 네임 바꿀때마다 따로 해줄 필요 없을듯
    }
    
   // 프로토콜로 못 불러왔음 자꾸 값을 넣었는데, 프로토콜끝나면 nil이 되버림.
    
    var audioFile : URL!
    let timePlayerSelector:Selector = #selector(WaitTableViewCell.updatePlayTime)
    
    func stopFunction(){
        buttonState(true, pause: false, stop: false)
        SharedVariable.Shared.audioPlayer.stop()
        
        progressTimer.invalidate()
        
        currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(0)
        progressView.progress = 0
        SharedVariable.Shared.audioPlayer = nil
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopFunction()
        //재생버튼 활성화 나머지 버튼 비활성화
        
        
    }
    
    func update ( _ refer: StorageReference , _ localURL: URL)  {
        self.downloadTask = refer.write(toFile: localURL)
        { url, error in
            if let error = error
            {   SharedVariable.Shared.showToast("there is no file ",(self.window?.rootViewController!.view)!)
                self.stopFunction()
            
            }
            else
            {
                print("succes")
                
                
            }
    }
    }
    func DownloadOrPlay(){
        self.buttonState(false, pause: true, stop: true)
        self.preparePlay()
        SharedVariable.Shared.audioPlayer.play()
        
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: self.timePlayerSelector, userInfo: nil, repeats: true)
    }
    @IBAction func Buttontouched ( _ sender: UIButton){
        if sender == playButton
        {
            
            if pauseButton.isEnabled == false, stopButton.isEnabled == true
            {
                
                self.buttonState(false, pause: true, stop: true)
                SharedVariable.Shared.audioPlayer.play()
                
            }
            else
            {   self.buttonState(false, pause: false, stop: false)
                let file: String = hideKey.text!
                        let stor = Storage.storage()
                        let storef = stor.reference()
                        let islandRef = storef.child("Recordings/이전/\(file).m4a")
                        
                        
                        
                        let localString = documentDirectory.appendingPathComponent("\(file).m4a")
                
                        self.audioFile = localString
                
                if FileManager.default.fileExists(atPath: localString.path) == false
                {
                    update(islandRef,localString)
                        
                        
                        let observer = downloadTask.observe(.success)
                        {snapshot in
                            print("download")
                            self.DownloadOrPlay()
                        }
                    
                }
                else
                {
                    print("local")
                        DownloadOrPlay()
                }
                
            }
            
            
        } else if sender == pauseButton, playButton.isEnabled == false, SharedVariable.Shared.audioPlayer.isPlaying == true {
            
            SharedVariable.Shared.audioPlayer.pause()
            
            buttonState(true, pause: false, stop: true)
            
        } else if sender == stopButton, playButton.isEnabled == false || pauseButton.isEnabled == false {
            stopFunction()
            
        }
        
    }
    @objc func updatePlayTime () {
        currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(SharedVariable.Shared.audioPlayer.currentTime)
        progressView.progress = Float(SharedVariable.Shared.audioPlayer.currentTime/SharedVariable.Shared.audioPlayer.duration)
    }
    func preparePlay () {
        
        
        if let audioFile = audioFile {
        do {
            SharedVariable.Shared.audioPlayer = try AVAudioPlayer(contentsOf: audioFile) //오류발생 가능 함수
        } catch let error as NSError { //오류타입
            print("error-initplay : \(error)")  //오류타입에 대한 처리 구문
        }
        }
        endTime.text = SharedVariable.Shared.convertNSTimeInterval2String(SharedVariable.Shared.audioPlayer.duration)
        SharedVariable.Shared.audioPlayer.delegate = self
        progressView.progress = 0
        SharedVariable.Shared.audioPlayer.volume = 5.0
        
        
    }
    func buttonState (_ start: Bool, pause: Bool, stop: Bool) {
        playButton.isEnabled = start
        pauseButton.isEnabled = pause
        stopButton.isEnabled = stop
        
    }
    override func awakeFromNib() {
        
    
        super.awakeFromNib()
        
        
    
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
