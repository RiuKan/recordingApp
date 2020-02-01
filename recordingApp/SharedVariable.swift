//
//  SharedVariable.swift
//  recordingApp
//
//  Created by 류강 on 05/10/2019.
//  Copyright © 2019 류강. All rights reserved.
//

import UIKit

class SharedVariable:NSObject  {
    static let Shared = SharedVariable()
    
    var nameOfFile: String!
    func convertNSTimeInterval2String(_ time:TimeInterval) -> String {
        //재생시간의 매개변수인 time값을 60으로 나눈 몫을 정수 값으로 변환하여 상수 min에 초기화
        let hour = Int(time/3600)
        
        let min = Int(time.truncatingRemainder(dividingBy: 3600)/60)
        //time값을 60으로 나눈 나머지 값을 정수 값으로 변환하여 상수 sec 값에 초기화 한다.
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        //이 두 값을 이용해서 "%02d:%02d" 형태의 문자열로 변환하여 상수에 초기화
        
        let strTime = String(format: "%02d:%02d:%02d",hour,min,sec)
        
        return strTime
     
    

}
    
}
