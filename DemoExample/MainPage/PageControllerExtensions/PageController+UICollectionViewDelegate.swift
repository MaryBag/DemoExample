//
//  PageController+UICollectionViewDelegate.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/15/19.
//  Copyright © 2019 BM. All rights reserved.
//

extension PageController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if let loadingView = view.viewWithTag(Constants.footerTag) as? UIActivityIndicatorView {
                if !isLoading && presenter?.nextPage != "" && (presenter?.getCount() ?? 0) != 0 {
                    let height = loadingView.frame.height
                    self.invisibleScrollView.contentSize.height += height
                    loadingView.startAnimating()
                    isLoading = true
                    self.presenter?.makeRequestToNextPage(completion: { [weak self] (check) in
                        DispatchQueue.main.async { [weak self] in
                            loadingView.stopAnimating()
                            self?.invisibleScrollView.contentSize.height -= height
                            loadingView.removeFromSuperview()
                            self?.isLoading = false
                            self?.updateCollection()
                        }
                    })
                }
            }
        }
    }
}
