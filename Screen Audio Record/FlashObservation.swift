//
//  Observation.swift
//  Screen Audio Record
//
//  Created by Umer on 16/08/22.
//

import Foundation
import Metal
struct FlashObservation: Codable {
   
    var startDate : String?
    var endDate : String?
    var audioPath : String?
    var duration : Double?
    var pathUrl : URL?
    var metaData : [EventTime] = []
    
    func toString()-> String? {
        
        
        return "Start Date : \(startDate!) \n\n End Date : \(endDate!) \n\n Duration : \(duration!) \n\n Audio Path : \(audioPath!) \n\n "
    }
   
}

struct EventTime : Codable {
    var timeStamp : String
    var secondOfAudio : Double
    
}
