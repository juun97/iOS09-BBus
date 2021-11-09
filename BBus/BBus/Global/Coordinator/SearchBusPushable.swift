//
//  SearchBusPushable.swift
//  BBus
//
//  Created by Kang Minsang on 2021/11/02.
//

import Foundation

protocol SearchBusPushable: Coordinator {
    func pushToSearchBus()
}

extension SearchBusPushable {
    func pushToSearchBus() {
        let coordinator = SearchCoordinator(presenter: self.navigationPresenter)
        coordinator.delegate = self.delegate
        self.delegate?.addChild(coordinator)
        coordinator.start()
    }
}
