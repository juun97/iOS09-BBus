//
//  AlarmSettingViewModel.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/01.
//

import Foundation
import Combine

typealias AlarmSettingBusStationInfo = (arsId: String, name: String, estimatedTime: Int)

class AlarmSettingViewModel {
    
    let useCase: AlarmSettingUseCase
    private let stationId: Int
    private let busRouteId: Int
    private let stationOrd: Int
    private let arsId: String
    @Published private(set) var busArriveInfos: [AlarmSettingBusArriveInfo]
    @Published private(set) var busStationInfos: [AlarmSettingBusStationInfo]
    private var cancellables: Set<AnyCancellable>
    
    init(useCase: AlarmSettingUseCase, stationId: Int, busRouteId: Int, stationOrd: Int, arsId: String) {
        self.useCase = useCase
        self.stationId = stationId
        self.busRouteId = busRouteId
        self.stationOrd = stationOrd
        self.arsId = arsId
        self.cancellables = []
        self.busArriveInfos = []
        self.busStationInfos = []
        self.binding()
        self.refresh()
        self.configureObserver()
        self.showBusStations()
    }
    
    private func configureObserver() {
        NotificationCenter.default.addObserver(forName: .oneSecondPassed, object: nil, queue: .main) { _ in
            self.descendTime()
        }
    }
    
    private func descendTime() {
        self.busArriveInfos = self.busArriveInfos.map {
            var arriveInfo = $0
            arriveInfo.arriveRemainTime?.descend()
            return arriveInfo
        }
    }
    
    func refresh() {
        self.useCase.busArriveInfoWillLoaded(stId: "\(self.stationId)",
                                             busRouteId: "\(self.busRouteId)",
                                             ord: "\(self.stationOrd)")
    }
    
    private func showBusStations() {
        self.useCase.busStationsInfoWillLoaded(busRouetId: "\(self.busRouteId)", arsId: self.arsId)
    }
    
    private func binding() {
        self.bindingBusArriveInfo()
        self.bindingBusStationsInfo()
    }
    
    private func bindingBusArriveInfo() {
        self.useCase.$busArriveInfo
            .receive(on: AlarmSettingUseCase.queue)
            .sink(receiveValue: { data in
                guard let data = data else { return }
                var arriveInfos: [AlarmSettingBusArriveInfo] = []
                arriveInfos.append(AlarmSettingBusArriveInfo(busArriveRemainTime: data.firstBusArriveRemainTime,
                                                             congestion: data.firstBusCongestion,
                                                             currentStation: data.firstBusCurrentStation,
                                                             plainNumber: data.firstBusPlainNumber))
                arriveInfos.append(AlarmSettingBusArriveInfo(busArriveRemainTime: data.secondBusArriveRemainTime,
                                                             congestion: data.secondBusCongestion,
                                                             currentStation: data.secondBusCurrentStation,
                                                             plainNumber: data.secondBusPlainNumber))
                self.busArriveInfos = arriveInfos
            })
            .store(in: &self.cancellables)
    }
    
    private func bindingBusStationsInfo() {
        self.useCase.$busStationsInfo
            .receive(on: AlarmSettingUseCase.queue)
            .sink(receiveValue: { infos in
                self.mappingStationsDTOtoAlarmSettingInfo()
            })
            .store(in: &self.cancellables)
    }
    
    private func mappingStationsDTOtoAlarmSettingInfo() {
        let initInfo: AlarmSettingBusStationInfo
        initInfo.estimatedTime = 0
        initInfo.arsId = ""
        initInfo.name = ""
        
        self.useCase.busStationsInfo.publisher
            .scan(initInfo, { before, info in
                let alarmSettingInfo: AlarmSettingBusStationInfo
                alarmSettingInfo.arsId = info.arsId
                alarmSettingInfo.estimatedTime = before.estimatedTime + (before.arsId != "" ? MovingStatusViewModel.averageSectionTime(speed: info.sectionSpeed, distance: info.fullSectionDistance) : 0)
                alarmSettingInfo.name = info.stationName
                return alarmSettingInfo
            })
            .collect()
            .assign(to: \.busStationInfos, on: self)
            .store(in: &self.cancellables)
    }
}
