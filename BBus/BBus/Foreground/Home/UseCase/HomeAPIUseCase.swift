//
//  HomeUseCase.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/01.
//

import Foundation
import Combine

protocol HomeAPIUsable: BaseUseCase {
    typealias HomeUseCases = GetFavoriteItemListUseCase & CreateFavoriteItemUseCase & GetStationListUseCase & GetRouteListUseCase & GetArrInfoByRouteListUseCase

    func fetchFavoriteData() -> AnyPublisher<[FavoriteItemDTO], Error>
    func fetchBusRemainTime(favoriteItem: FavoriteItemDTO) -> AnyPublisher<ArrInfoByRouteDTO, Error>
    func fetchStation() -> AnyPublisher<[StationDTO], Error>
    func fetchBusRoute() -> AnyPublisher<[BusRouteDTO], Error>
}

final class HomeAPIUseCase: HomeAPIUsable {

    private let useCases: HomeUseCases

    init(useCases: HomeUseCases) {
        self.useCases = useCases
    }

    func fetchFavoriteData() -> AnyPublisher<[FavoriteItemDTO], Error> {
        return self.useCases.getFavoriteItemList()
            .decode(type: [FavoriteItemDTO]?.self, decoder: PropertyListDecoder())
            .tryMap({ item in
                guard let item = item else { throw BBusAPIError.wrongFormatError }
                return item
            })
            .eraseToAnyPublisher()
    }

    func fetchBusRemainTime(favoriteItem: FavoriteItemDTO) -> AnyPublisher<ArrInfoByRouteDTO, Error> {
        return self.useCases.getArrInfoByRouteList(stId: favoriteItem.stId,
                                                   busRouteId: favoriteItem.busRouteId,
                                                   ord: favoriteItem.ord)
            .decode(type: ArrInfoByRouteResult.self, decoder: JSONDecoder())
            .tryMap({ item in
                let result = item.msgBody.itemList
                guard let item = result.first else { throw BBusAPIError.wrongFormatError }
                return item
            })
            .eraseToAnyPublisher()
    }

    func fetchStation() -> AnyPublisher<[StationDTO], Error> {
        self.useCases.getStationList()
            .decode(type: [StationDTO]?.self, decoder: JSONDecoder())
            .tryMap({ item in
                guard let item = item else { throw BBusAPIError.wrongFormatError }
                return item
            })
            .eraseToAnyPublisher()
    }

    func fetchBusRoute() -> AnyPublisher<[BusRouteDTO], Error> {
        return self.useCases.getRouteList()
            .decode(type: [BusRouteDTO]?.self, decoder: JSONDecoder())
            .tryMap({ item in
                guard let item = item else { throw BBusAPIError.wrongFormatError }
                return item
            })
            .eraseToAnyPublisher()
    }
}
