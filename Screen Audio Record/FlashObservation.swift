//
//  Observation.swift
//  Screen Audio Record
//
//  Created by Umer on 16/08/22.
//

import Foundation
struct FlashObservation: Codable{
    var startDate : String?
    var endDate : String?
    var audioPath : String?
    var duration : Double?
    var pathUrl : URL?
}
