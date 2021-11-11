//
//  SearchBusViewController.swift
//  BBus
//
//  Created by 김태훈 on 2021/11/01.
//

import UIKit

class SearchViewController: UIViewController {

    weak var coordinator: SearchCoordinator?
    private lazy var searchView = SearchView()
    private let viewModel: SearchViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
        self.configureUI()
        self.configureDelegate()

    }

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }

    // MARK: - Configuration
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchView.configureInitialTabStatus(type: .bus)
    }

    private func configureDelegate() {
        self.searchView.configureBackButtonDelegate(self)
        self.searchView.configureDelegate(self)
    }

    private func configureLayout() {
        self.view.addSubview(self.searchView)
        self.searchView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.searchView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.searchView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.searchView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func configureUI() {
        self.view.backgroundColor = BBusColor.white
    }
}

extension SearchViewController: SearchBackButtonDelegate {
    func shouldNavigationPop() {
        self.coordinator?.terminate()
    }
}

// MARK: - Delegate : UICollectionView
extension SearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.searchView.currentSearchType == SearchType.bus {
            self.coordinator?.pushToBusRoute()
        }
        else {
            self.coordinator?.pushToStation()
        }
    }
}

// MARK: - DataSource : UICollectionView
extension SearchViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SimpleCollectionHeaderView.identifier, for: indexPath) as? SimpleCollectionHeaderView else { return UICollectionReusableView() }
        header.configureLayout()
        header.configure(title: (indexPath.section % 2 == 0) ? "경기" : "부산")
        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.identifier, for: indexPath) as? SearchResultCollectionViewCell else { return UICollectionViewCell() }
        if collectionView.frame.origin.x == 0 {
            cell.configureUI(title: "15", detailInfo: NSMutableAttributedString(string: "가평군 일반버스"))
        }
        else {
            let fullText = "14911 | 공항철도.홍대입구역 방면"
            let range = (fullText as NSString).range(of: "|")
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor,
                                          value: BBusColor.bbusLightGray as Any,
                                          range: range)
            cell.configureUI(title: "홍대입구", detailInfo: attributedString)
        }
        cell.configureLayout()
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchView.hideKeyboard()
    }
}

// MARK: - DelegateFlowLayout : UICollectionView
extension SearchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: SearchResultCollectionViewCell.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: SimpleCollectionHeaderView.height)
    }
}

extension SearchViewController: TextFieldDelegate {
    func shouldRefreshSearchResult(by keyword: String) {
        self.viewModel?.configure(keyword: keyword)
    }
}
