//
//  SharedVariable.swift
//  recordingApp
//
//  Created by 류강 on 05/10/2019.
//  Copyright © 2019 류강. All rights reserved.
//

import UIKit
import AVFoundation
class SharedVariable:NSObject {
    
    static let Shared = SharedVariable()
    
    var audioPlayer: AVAudioPlayer!
    var nameOfFile: String!
    var valueLast: Dictionary<String,Dictionary<String, Dictionary<String, String>>> = [:] 
    var tableview: UITableView = UITableView.init()
    var nameRecieve = Dictionary<String,Array<String>>()
    var sortedArray = Array<String>(){didSet{
        
        namerecieveMaking()
        
        tableview.reloadData()
        }}
    var row: Int = 0
    var section: Int = 0
    var folderCount = Dictionary<String,Int>()
    var sortedArrayi: String!
    func namerecieveMaking() {
        for i in 0...folderCount.count - 1{
            sortedArrayi = sortedArray[i]
            if self.valueLast.keys.contains(sortedArrayi) == true {
            nameRecieve[sortedArrayi] =  Array(self.valueLast[sortedArrayi]!.keys).sorted(by: dicDateSortFunc(s1:s2:))
            }else{
                self.valueLast[sortedArrayi] = Dictionary<String,Dictionary<String,String>>()
                nameRecieve[sortedArrayi] = Array<String>()
            }
        }
    }
    func dicDateSortFunc (s1: String, s2: String) -> Bool {
        let d1 = self.valueLast[sortedArrayi]?[s1]?["날짜"]
        let d2 = self.valueLast[sortedArrayi]?[s2]?["날짜"]
        let t1 = self.valueLast[sortedArrayi]?[s1]?["시간"]
        let t2 = self.valueLast[sortedArrayi]?[s2]?["시간"]
        
        var result1 : Date!
        var result2 : Date!
        var resultTime1 : Date!
        var resultTime2 : Date!
        
        let formatterD = DateFormatter()
        formatterD.locale = Locale(identifier: "ko_KR")
        formatterD.dateFormat = "yyyy.mm.dd"
        let formatterT = DateFormatter()
        formatterT.locale = Locale(identifier: "ko_KR")
        formatterT.timeStyle = .medium
        if let d1 = d1, let d2 = d2, let t1 = t1, let t2 = t2
        {
            
            
            let date1 = formatterD.date(from: "\(d1)")
            let date2 = formatterD.date(from: "\(d2)")
            
            let time1 = formatterT.date(from: "\(t1)")
            let time2 = formatterT.date(from: "\(t2)")
            
            if let date1 = date1, let date2 = date2, let time1 = time1, let time2 = time2
            {
                result1 = date1 ; result2 = date2
                resultTime1 = time1 ; resultTime2 = time2
                
                
            }
            
        }
        if result1 != result2 {
            return result1 > result2
        } else {
            return resultTime1 > resultTime2
        }
        
    }
    
    func showToast(_ message : String,_ view: UIView) {
        let width_variable:CGFloat = 10
        let toastLabel = UILabel(frame: CGRect(x: width_variable, y: view.frame.size.height-100, width: view.frame.size.width-2*width_variable, height: 35))
        // 뷰가 위치할 위치를 지정해준다. 여기서는 아래로부터 100만큼 떨어져있고, 너비는 양쪽에 10만큼 여백을 가지며, 높이는 35로
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    func convertNSTimeInterval2String(_ time:TimeInterval) -> String {
        //재생시간의 매개변수인 time값을 60으로 나눈 몫을 정수 값으로 변환하여 상수 min에 초기화
        if time >= 3600 {
        let hour = Int(time/3600)
        
        let min = Int(time.truncatingRemainder(dividingBy: 3600)/60)
        //time값을 60으로 나눈 나머지 값을 정수 값으로 변환하여 상수 sec 값에 초기화 한다.
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        //이 두 값을 이용해서 "%02d:%02d" 형태의 문자열로 변환하여 상수에 초기화
        
        let strTime = String(format: "%02d:%02d:%02d",hour,min,sec)
        
        return strTime
        }
        else {
            let min = Int(time/60)
            //time값을 60으로 나눈 나머지 값을 정수 값으로 변환하여 상수 sec 값에 초기화 한다.
            let sec = Int(time.truncatingRemainder(dividingBy: 60))
            //이 두 값을 이용해서 "%02d:%02d" 형태의 문자열로 변환하여 상수에 초기화
            
            let strTime = String(format: "%02d:%02d",min,sec)
            
            return strTime
        }
     
    }
}
