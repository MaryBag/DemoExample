//
//  PageController+UICollectionViewDataSource.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/15/19.
//  Copyright © 2019 BM. All rights reserved.
//

extension PageController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else {return 0}
        return presenter.getCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryBox.self), for: indexPath)
        if let cell = cell as? CategoryBox {
            cell.setup()
            if !(presenter?.isLoadingList ?? true) {
                presenter?.setContentForCell(cell: cell, id: indexPath.row)
                return cell
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectCell(id: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer", for: indexPath)
            let loading = UIActivityIndicatorView()
            loading.style = UIActivityIndicatorView.Style.medium
            loading.translatesAutoresizingMaskIntoConstraints = false
            loading.tintColor = UIColor.gray
            loading.tag = Constants.footerTag
            view.addSubview(loading)
            view.addConstraint(NSLayoutConstraint(item: loading, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: Constants.zero))
            view.addConstraint(NSLayoutConstraint(item: loading, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: Constants.zero))
            return view
        }
        return UICollectionReusableView()
    }
    
}
