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
protocol sendData {
    func senddata (_ data1:Dictionary<String, Dictionary<String, String>>)
}
class WaitTableViewCell: UITableViewCell, AVAudioPlayerDelegate, UINavigationControllerDelegate,SenddataDelegate {
    var delegate: sendData?
    var progressTimer : Timer!
    var audioPlayer: AVAudioPlayer!
    let maxVolume: Float = 10.0
    var ref: DatabaseReference!
    var repeater: Int = 0
    var downloadTask: StorageDownloadTask!
    var row: Int!
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var valueLast = Dictionary<String, Dictionary<String, String>>()
    var tableview: UITableView!
    var nameRecieve: Array<String>!
    
    // 실행 ui
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    
    @IBOutlet weak var fileDate: UILabel!
    @IBOutlet weak var fileName: UITextField!
    
    @IBOutlet weak var fileNameWait: UILabel!
    @IBOutlet weak var fileDateWait: UILabel!
    @IBOutlet weak var filePlayTimeWait: UILabel!
    
    @IBAction func filenameChange (_ sender:UITextField) {
        let name  = fileName.text
        let id = nameRecieve[row]
        if let name = name { ref.child("FileNames").child("\(id)").child("파일이름").setValue("\(name)",withCompletionBlock:{ (Error:Error?, DatabaseReference:DatabaseReference) in
            
            })
            valueLast[id]!["파일이름"] = name
        }
        delegate?.senddata(valueLast)
           // 여기 valueLast.keys만 변수 따로 담아주면 네임 바꿀때마다 따로 해줄 필요 없을듯
    }
    func sendData(data1: Int, data2: Dictionary<String, Dictionary<String, String>>,data3: UITableView,data4:Array<String>) {
        row = data1
        valueLast = data2
        tableview = data3
        nameRecieve = data4
        
        
    }
   
    
    var audioFile : URL!
    let timePlayerSelector:Selector = #selector(WaitTableViewCell.updatePlayTime)
    
   
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer.stop()
        progressTimer.invalidate()
        //재생버튼 활성화 나머지 버튼 비활성화
        
        
    }
    
    func update ( _ refer: StorageReference , _ localURL: URL)  {
        self.downloadTask = refer.write(toFile: localURL)
        { url, error in
            if let error = error
            {   SharedVariable.Shared.showToast("there is no file ",(self.window?.rootViewController!.view)!)
            
            }
            else
            {
                print("succes")
                
                
            }
    }
    }

    @IBAction func Buttontouched ( _ sender: UIButton){
        if sender == playButton {
            
            if pauseButton.isEnabled == false, stopButton.isEnabled == true{
                buttonState(false, pause: true, stop: true)
                
                audioPlayer.play()
                
            }
            else {
                
            if let file = SharedVariable.Shared.nameOfFile
            {
            let stor = Storage.storage()
            let storef = stor.reference()
            let islandRef = storef.child("Recordings/이전/\(file).m4a")
            
            
            
            let localURL = documentDirectory.appendingPathComponent("\(file).m4a")
            
                
                update(islandRef,localURL)
            
                
            
            let observer = downloadTask.observe(.success) { snapshot in
                
                    
                    
                    self.audioFile = localURL
                    self.preparePlay()
                    self.audioPlayer.play()
                self.buttonState(false, pause: true, stop: true)
                    self.progressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: self.timePlayerSelector, userInfo: nil, repeats: true)
                       }
            }
            }
            
            
        } else if sender == pauseButton, playButton.isEnabled == false, audioPlayer.isPlaying == true {
            
            audioPlayer.pause()
            
            buttonState(true, pause: false, stop: true)
            
        } else if sender == stopButton, playButton.isEnabled == false || pauseButton.isEnabled == false {
            buttonState(true, pause: false, stop: false)
            audioPlayer.stop()
            
            progressTimer.invalidate()
            
            currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(0)
            progressView.progress = 0
            
            
        }
        
    }
    @objc func updatePlayTime () {
        currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(audioPlayer.currentTime)
        progressView.progress = Float(audioPlayer.currentTime/audioPlayer.duration)
    }
    func preparePlay () {
        
        
        if let audioFile = audioFile {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile) //오류발생 가능 함수
        } catch let error as NSError { //오류타입
            print("error-initplay : \(error)")  //오류타입에 대한 처리 구문
        }
        }
        endTime.text = SharedVariable.Shared.convertNSTimeInterval2String(audioPlayer.duration)
        audioPlayer.delegate = self
        progressView.progress = 0
        audioPlayer.volume = 5.0
        
        
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
