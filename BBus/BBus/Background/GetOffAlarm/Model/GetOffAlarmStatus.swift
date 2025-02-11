//
//  GetOffAlarmStatus.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/24.
//

import Foundation

struct GetOffAlarmStatus {
    let targetOrd: Int
    let busRouteId: Int
    let arsId: String

    init(targetOrd: Int, busRouteId: Int, arsId: String) {
        self.targetOrd = targetOrd
        self.busRouteId = busRouteId
        self.arsId = arsId
    }
}
