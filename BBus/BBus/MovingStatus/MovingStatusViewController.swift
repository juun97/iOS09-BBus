//
//  MovingStatusViewController.swift
//  BBus
//
//  Created by Minsang on 2021/11/15.
//

import UIKit
import Combine

typealias MovingStatusCoordinator = MovingStatusOpenCloseDelegate & MovingStatusFoldUnfoldDelegate

final class MovingStatusViewController: UIViewController {

    weak var coordinator: MovingStatusCoordinator?
    private lazy var movingStatusView = MovingStatusView()
    private let viewModel: MovingStatusViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private var busIcon: UIImage?

    init(viewModel: MovingStatusViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.binding()
        self.configureLayout()
        self.configureDelegate()
        self.configureBusTag()
        self.fetch()
    }
    
    // MARK: - Configure
    private func configureLayout() {
        self.view.addSubview(self.movingStatusView)
        self.movingStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.movingStatusView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.movingStatusView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.movingStatusView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.movingStatusView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func configureDelegate() {
        self.movingStatusView.configureDelegate(self)
    }
    
    private func configureBusTag() {
        self.movingStatusView.addBusTag()
    }
    
    private func configureColor() {
        self.view.backgroundColor = BBusColor.white
    }

    private func binding() {
        self.bindingHeaderBusInfo()
        self.bindingRemainTime()
        self.bindingCurrentStation()
        self.bindingStationInfos()
    }

    private func bindingHeaderBusInfo() {
        self.viewModel?.$busInfo
            .receive(on: MovingStatusUsecase.queue)
            .sink(receiveValue: { [weak self] busInfo in
                guard let busInfo = busInfo else { return }
                DispatchQueue.main.async {
                    self?.movingStatusView.configureBusName(to: busInfo.busName)
                    self?.configureBusColor(type: busInfo.type)
                }
            })
            .store(in: &self.cancellables)
    }

    private func bindingRemainTime() {
        self.viewModel?.$remainingTime
            .receive(on: MovingStatusUsecase.queue)
            .sink(receiveValue: { [weak self] remainingTime in
                DispatchQueue.main.async {
                    self?.movingStatusView.configureHeaderInfo(currentStation: self?.viewModel?.currentStation, remainTime: remainingTime)
                }
            })
            .store(in: &self.cancellables)
    }

    private func bindingCurrentStation() {
        self.viewModel?.$currentStation
            .receive(on: MovingStatusUsecase.queue)
            .sink(receiveValue: { [weak self] currentStation in
                DispatchQueue.main.async {
                    self?.movingStatusView.configureHeaderInfo(currentStation: currentStation, remainTime: self?.viewModel?.remainingTime)
                }
            })
            .store(in: &self.cancellables)
    }

    private func bindingStationInfos() {
        self.viewModel?.$stationInfos
            .receive(on: MovingStatusUsecase.queue)
            .sink(receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.movingStatusView.reload()
                }
            })
            .store(in: &self.cancellables)
    }

    private func configureBusColor(type: RouteType) {
        let color: UIColor?

        switch type {
        case .mainLine:
            color = BBusColor.bbusTypeBlue
            self.busIcon = BBusImage.blueBusIcon
        case .broadArea:
            color = BBusColor.bbusTypeRed
            self.busIcon = BBusImage.redBusIcon
        case .customized:
            color = BBusColor.bbusTypeGreen
            self.busIcon = BBusImage.greenBusIcon
        case .circulation:
            color = BBusColor.bbusTypeCirculation
            self.busIcon = BBusImage.circulationBusIcon
        case .lateNight:
            color = BBusColor.bbusTypeBlue
            self.busIcon = BBusImage.blueBusIcon
        case .localLine:
            color = BBusColor.bbusTypeGreen
            self.busIcon = BBusImage.greenBusIcon
        }

        self.movingStatusView.configureColor(to: color)
    }

    private func fetch() {
        self.viewModel?.fetch()
    }
}

// MARK: - DataSource: UITableView
extension MovingStatusViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.stationInfos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovingStatusTableViewCell.reusableID, for: indexPath) as? MovingStatusTableViewCell else { return UITableViewCell() }
        guard let stationInfo = self.viewModel?.stationInfos[indexPath.row] else { return cell }
        dump(stationInfo)

        switch indexPath.item {
        case 0:
            cell.configure(type: .getOn)
        case 9:
            cell.configure(type: .getOff)
        default:
            cell.configure(type: .waypoint)
        }
        
        return cell
    }
}

// MARK: - Delegate : UITableView
extension MovingStatusViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GetOffTableViewCell.cellHeight
    }
}

// MARK: - Delegate : BottomIndicatorButton
extension MovingStatusViewController: BottomIndicatorButtonDelegate {
    func shouldUnfoldMovingStatusView() {
        // Coordinator에게 Unfold 요청
        print("bottom indicator button is touched")
        UIView.animate(withDuration: 0.3) {
            self.coordinator?.unfold()
        }
    }
}

// MARK: - Delegate : BottomIndicatorButton
extension MovingStatusViewController: FoldButtonDelegate {
    func shouldFoldMovingStatusView() {
        // Coordinator에게 fold 요청
        print("fold button is touched")
        UIView.animate(withDuration: 0.3) {
            self.coordinator?.fold()
        }
    }
}

// MARK: - Delegate : EndAlarmButton
extension MovingStatusViewController: EndAlarmButtonDelegate {
    func shouldEndAlarm() {
        // alarm 종료
        print("end the alarm")
        self.coordinator?.close()
    }
}
