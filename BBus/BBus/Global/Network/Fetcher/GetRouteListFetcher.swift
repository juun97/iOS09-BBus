//
//  GetRouteListFetcher.swift
//  BBus
//
//  Created by 이지수 on 2021/11/10.
//

import Foundation
import Combine

protocol GetRouteListFetchable {
    func fetch(on queue: DispatchQueue) -> AnyPublisher<Data, Error>
}

final class PersistentGetRouteListFetcher: GetRouteListFetchable {
    func fetch(on queue: DispatchQueue) -> AnyPublisher<Data, Error> {
        return Persistent.shared.get(file: "BusRouteList", type: "json", on: queue)
    }
}
