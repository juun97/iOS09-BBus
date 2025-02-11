//
//  StationBodyCollectionViewCell.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/07.
//

import UIKit

protocol LikeButtonDelegate: AnyObject {
    func likeStationBus(at: UICollectionViewCell)
    func cancelLikeStationBus(at: UICollectionViewCell)
}

final class StationBodyCollectionViewCell: FavoriteCollectionViewCell {

    private weak var likeButtonDelegate: LikeButtonDelegate? {
        didSet {
            let action = UIAction(handler: {[weak self] _ in
                guard let self = self,
                      let delegate = self.likeButtonDelegate else { return }
                self.likeButton.isSelected ? delegate.cancelLikeStationBus(at: self) : delegate.likeStationBus(at: self)
            })
            self.likeButton.removeTarget(nil, action: nil, for: .allEvents)
            self.likeButton.addAction(action, for: .touchUpInside)
        }
    }

    override class var height: CGFloat { return 90 }
    override var busNumberYAxisMargin: CGFloat { return -self.busNumberFontSize/1.5 }
    override var busNumberFontSize: CGFloat { return super.busNumberFontSize * (FavoriteCollectionViewCell.height / Self.height) * 1.2 }
    override var busNumberLeadingInterval: CGFloat { return self.likeButtonleadingInterval * 2 + self.likeButtonHeightWidth }
    private let likeButtonleadingInterval: CGFloat = 5
    private let likeButtonHeightWidth: CGFloat = 40

    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = BBusColor.bbusGray6
        button.setImage(BBusImage.star, for: .normal)
        return button
    }()
    lazy var directionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = BBusColor.bbusGray
        return label
    }()

    override func configureLayout() {
        super.configureLayout()

        self.addSubviews(self.likeButton, self.directionLabel)
        
        NSLayoutConstraint.activate([
            self.likeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.likeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: likeButtonleadingInterval),
            self.likeButton.widthAnchor.constraint(equalToConstant: self.likeButtonHeightWidth),
            self.likeButton.heightAnchor.constraint(equalToConstant: self.likeButtonHeightWidth)
        ])

        let directionLabelTopInterval: CGFloat = 5
        NSLayoutConstraint.activate([
            self.directionLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: directionLabelTopInterval),
            self.directionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.busNumberLeadingInterval),
            self.directionLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.centerXAnchor)
        ])
    }
    
    func configure(busNumber: String, routeType: RouteType?, direction: String, firstBusTime: String?, firstBusRelativePosition: String?, firstBusCongestion: String?, secondBusTime: String?, secondBusRelativePosition: String?, secondBusCongestion: String?) {
        super.configure(busNumber: busNumber,
                        routeType: routeType,
                        firstBusTime: firstBusTime,
                        firstBusRelativePosition: firstBusRelativePosition,
                        firstBusCongestion: firstBusCongestion,
                        secondBusTime: secondBusTime,
                        secondBusRelativePosition: secondBusRelativePosition,
                        secondBusCongestion: secondBusCongestion)
        self.directionLabel.text = direction
    }
    
    func configure(delegate: LikeButtonDelegate & AlarmButtonDelegate) {
        self.likeButtonDelegate = delegate
        super.configureDelegate(delegate)
    }
    
    func configureButton(status: Bool) {
        self.likeButton.isSelected = status
        self.likeButton.tintColor = status ? BBusColor.bbusLikeYellow : BBusColor.bbusGray6 
    }
}
