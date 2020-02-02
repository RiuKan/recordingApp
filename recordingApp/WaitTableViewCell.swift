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
    var audioPlayer: AVAudioPlayer!
    let maxVolume: Float = 10.0
    var ref: DatabaseReference!
    let filemag = FileManager.default
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    // 실행 ui
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    
    @IBOutlet weak var fileDate: UILabel!
    @IBOutlet weak var fileName: UILabel!
    
    @IBOutlet weak var fileNameWait: UILabel!
    @IBOutlet weak var fileDateWait: UILabel!
    @IBOutlet weak var filePlayTimeWait: UILabel!
    
    
    
   
    
    var audioFile : URL!
    let timePlayerSelector:Selector = #selector(WaitTableViewCell.updatePlayTime)
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressTimer.invalidate()
        //재생버튼 활성화 나머지 버튼 비활성화
        buttonState(true, pause: false, stop: false)
    }
    @IBAction func Buttontouched ( _ sender: UIButton){
        if sender == playButton {
            buttonState(false, pause: true, stop: true)
            if let file = SharedVariable.Shared.nameOfFile
            {
            let stor = Storage.storage()
            let storef = stor.reference()
            let islandRef = storef.child("Recordings/\(file).m4a")
            
            
            
            let localURL = documentDirectory.appendingPathComponent("\(file).m4a")
            
            
            let downloadTask = islandRef.write(toFile: localURL)
            { url, error in
                if let error = error
                {
                   print("error")
                }
                else
                {
                    print("succes")
                }
            }
            
            let observer = downloadTask.observe(.progress) { snapshot in
                if let test = snapshot.progress?.completedUnitCount, snapshot.progress?.isFinished == true {
                    
                    
                    self.audioFile = localURL
                    self.preparePlay()
                    self.audioPlayer.play()
                    self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: self.timePlayerSelector, userInfo: nil, repeats: true)
                }         }
            }
            
            
            
        } else if sender == pauseButton {
            audioPlayer.pause()
            buttonState(true, pause: false, stop: true)
            
        } else if sender == stopButton {
            
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(0)
            buttonState(true, pause: false, stop: false)
            
            progressTimer.invalidate()
        }
        
    }
    @objc func updatePlayTime () {
        currentTime.text = SharedVariable.Shared.convertNSTimeInterval2String(audioPlayer.currentTime)
        progressView.progress = Float(audioPlayer.currentTime/audioPlayer.duration)
    }
    func preparePlay () {
        
        
        if let audioFile = audioFile {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile ) //오류발생 가능 함수
        } catch let error as NSError { //오류타입
            print("error-initplay : \(error)")  //오류타입에 대한 처리 구문
        }
        }
        endTime.text = SharedVariable.Shared.convertNSTimeInterval2String(audioPlayer.duration)
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        progressView.progress = 0
        audioPlayer.volume = 5.0
        buttonState( true, pause: false, stop: false)
        
    }
    func buttonState (_ start: Bool, pause: Bool, stop: Bool) {
        playButton.isEnabled = start
        pauseButton.isEnabled = pause
        stopButton.isEnabled = stop
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }

}
