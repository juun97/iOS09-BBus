//
//  HomeCoordinator.swift
//  BBus
//
//  Created by Kang Minsang on 2021/11/02.
//

import UIKit

final class HomeCoordinator: SearchPushable, BusRoutePushable, AlarmSettingPushable, StationPushable {
    weak var delegate: CoordinatorDelegate?
    var navigationPresenter: UINavigationController

    init(presenter: UINavigationController) {
        self.navigationPresenter = presenter
    }

    func start() {
        let apiUseCases = BBusAPIUseCases(networkService: NetworkService(),
                                          persistenceStorage: PersistenceStorage(),
                                          requestFactory: RequestFactory())
        let useCase = HomeUseCase(usecases: apiUseCases)
        let viewModel = HomeViewModel(useCase: useCase)
        let viewController = HomeViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationPresenter.pushViewController(viewController, animated: false) // present
    }
}
