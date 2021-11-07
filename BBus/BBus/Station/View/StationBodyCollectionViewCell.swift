//
//  StationBodyCollectionViewCell.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/07.
//

import UIKit

protocol LikeButtonDelegate {
    func likeStationBus()
}

class StationBodyCollectionViewCell: FavoriteCollectionViewCell {

    private var likeButtonDelegate: LikeButtonDelegate? {
        didSet {
            let action = UIAction(handler: {[weak self] _ in
                self?.likeButtonDelegate?.likeStationBus()
                self?.likeButton.tintColor = self?.likeButton.tintColor == MyColor.bbusLikeYellow ? MyColor.systemGray6 : MyColor.bbusLikeYellow
            })
            self.likeButton.removeTarget(nil, action: nil, for: .allEvents)
            self.likeButton.addAction(action, for: .touchUpInside)
        }
    }
    override var height: CGFloat { return 90 }
    override var busNumberYAxisMargin: CGFloat { return -self.busNumberFontSize/1.5 }
    override var busNumberFontSize: CGFloat { return super.busNumberFontSize * (super.height / self.height) * 1.2 }
    override var busNumberLeadingInterval: CGFloat { return self.likeButtonleadingInterval * 2 + self.likeButtonHeightWidth }
    private let likeButtonleadingInterval: CGFloat = 5
    private let likeButtonHeightWidth: CGFloat = 40

    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = MyColor.systemGray6
        button.setImage(MyImage.filledStar, for: .normal)
        return button
    }()
    lazy var directionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = MyColor.bbusGray
        return label
    }()

    override func configureLayout() {
        super.configureLayout()

        self.addSubview(self.likeButton)
        self.likeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.likeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.likeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: likeButtonleadingInterval),
            self.likeButton.widthAnchor.constraint(equalToConstant: self.likeButtonHeightWidth),
            self.likeButton.heightAnchor.constraint(equalToConstant: self.likeButtonHeightWidth)
        ])

        let directionLabelTopInterval: CGFloat = 5
        self.addSubview(self.directionLabel)
        self.directionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.directionLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: directionLabelTopInterval),
            self.directionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.busNumberLeadingInterval),
            self.directionLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.centerXAnchor)
        ])
    }
    
    func configure(busNumber: String, direction: String, firstBusTime: String, firstBusRelativePosition: String, firstBusCongestion: String, secondBusTime: String, secondBusRelativePosition: String, secondBusCongsetion: String) {
        super.configure(busNumber: busNumber,
                        firstBusTime: firstBusTime,
                        firstBusRelativePosition: firstBusRelativePosition,
                        firstBusCongestion: firstBusCongestion,
                        secondBusTime: secondBusTime,
                        secondBusRelativePosition: secondBusRelativePosition,
                        secondBusCongsetion: secondBusCongsetion)
        self.directionLabel.text = direction
    }
    
    func configure(delegate: LikeButtonDelegate & AlarmButtonDelegate) {
        self.likeButtonDelegate = delegate
        super.configureDelegate(delegate)
    }
}
