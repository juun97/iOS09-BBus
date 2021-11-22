//
//  StationUseCase.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/01.
//

import Foundation
import Combine

class StationUsecase {
    static let queue = DispatchQueue.init(label: "station")
    
    typealias StationUsecases = GetStationByUidItemUsecase & GetStationListUsecase & CreateFavoriteItemUsecase & DeleteFavoriteItemUsecase & GetFavoriteItemListUsecase
    
    private let usecases: StationUsecases
    @Published private(set) var busArriveInfo: [StationByUidItemDTO]
    @Published private(set) var stationInfo: StationDTO?
    @Published private(set) var favoriteItems: [FavoriteItemDTO] // need more
    @Published private(set) var networkError: Error?
    private var cancellables: Set<AnyCancellable>
    
    init(usecases: StationUsecases) {
        self.usecases = usecases
        self.busArriveInfo = []
        self.stationInfo = nil
        self.cancellables = []
        self.favoriteItems = []
        self.networkError = nil
        self.getFavoriteItems()
    }
    
    func stationInfoWillLoad(with arsId: String) {
        Self.queue.async { [weak self] in
            guard let self = self else { return }

            self.usecases.getStationList()
                .receive(on: Self.queue)
                .decode(type: [StationDTO].self, decoder: JSONDecoder())
                .tryMap({ stations in
                    guard let result = self.findStation(in: stations, with: arsId) else { throw BBusAPIError.wrongFormatError }
                    return result
                })
                .retry({
                    self.stationInfoWillLoad(with: arsId)
                }, handler: { error in
                    self.networkError = error
                })
                .assign(to: \.stationInfo, on: self)
                .store(in: &self.cancellables)
        }
    }
    
    private func findStation(in stations: [StationDTO], with arsId: String) -> StationDTO? {
        let station = stations.filter() { $0.arsID == arsId }
        return station.first
    }
    
    func refreshInfo(about arsId: String) {
        Self.queue.async { [weak self] in
            guard let self = self else { return }

            self.usecases.getStationByUidItem(arsId: arsId)
                .receive(on: Self.queue)
                .tryMap({ data -> [StationByUidItemDTO] in
                    guard let result = BBusXMLParser().parse(dtoType: StationByUidItemResult.self, xml: data) else { throw BBusAPIError.wrongFormatError }
                    return result.body.itemList
                })
                .retry({
                    self.refreshInfo(about: arsId)
                }, handler: { error in
                    self.networkError = error
                })
                .assign(to: \.busArriveInfo, on: self)
                .store(in: &self.cancellables)
        }
    }
    
    func add(favoriteItem: FavoriteItemDTO) {
        Self.queue.async { [weak self] in
            guard let self = self else { return }

            self.usecases.createFavoriteItem(param: favoriteItem)
                .receive(on: Self.queue)
                .retry({
                    self.add(favoriteItem: favoriteItem)
                }, handler: { error in
                    self.networkError = error
                })
                .sink(receiveValue: { _ in
                    self.getFavoriteItems()
                })
                .store(in: &self.cancellables)
        }
    }
    
    func remove(favoriteItem: FavoriteItemDTO) {
        Self.queue.async { [weak self] in
            guard let self = self else { return }

            self.usecases.deleteFavoriteItem(param: favoriteItem)
                .receive(on: Self.queue)
                .retry({
                    self.remove(favoriteItem: favoriteItem)
                }, handler: { error in
                    self.networkError = error
                })
                .sink(receiveValue: { _ in
                    self.getFavoriteItems()
                })
                .store(in: &self.cancellables)
        }
    }
    
    private func getFavoriteItems() {
        Self.queue.async { [weak self] in
            guard let self = self else { return }

            self.usecases.getFavoriteItemList()
                .receive(on: Self.queue)
                .decode(type: [FavoriteItemDTO].self, decoder: PropertyListDecoder())
                .retry({
                    self.getFavoriteItems()
                }, handler: { error in
                    self.networkError = error
                })
                .assign(to: \.favoriteItems, on: self)
                .store(in: &self.cancellables)
        }
    }
}
