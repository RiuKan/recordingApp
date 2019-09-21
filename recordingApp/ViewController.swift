//
//  ViewController.swift
//  recordingApp
//
//  Created by 류강 on 21/09/2019.
//  Copyright © 2019 류강. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate,AVAudioRecorderDelegate {
    let maxVolume: Float = 10.0
    var audioPlayer: AVAudioPlayer!
    var audioFile : URL!
    

    @IBOutlet weak var modeName: UILabel!
    
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var playSlider: UISlider!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var recordingTime: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

