//
//  GetStationListUseCase.swift
//  BBus
//
//  Created by 이지수 on 2021/11/29.
//

import Foundation
import Combine

protocol GetStationListUseCase {
    func getStationList() -> AnyPublisher<Data, Error>
}

extension BBusAPIUseCases: GetStationListUseCase {
    func getStationList() -> AnyPublisher<Data, Error> {
        let fetcher: GetStationListFetchable = PersistenceGetStationListFetcher(persistenceStorage: self.persistenceStorage)
        return fetcher
            .fetch()
            .tryCatch({ error -> AnyPublisher<Data, Error> in
                return fetcher
                    .fetch()
            })
            .retry(TokenManager.maxTokenCount)
            .eraseToAnyPublisher()
    }
}
