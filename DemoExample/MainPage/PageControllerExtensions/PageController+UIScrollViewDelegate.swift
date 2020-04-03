//
//  PageController+UIScrollViewDelegate.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/15/19.
//  Copyright © 2019 BM. All rights reserved.
//

extension PageController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == invisibleScrollView {
            if scrollView.contentOffset.y < maxHeaderOffsetY {
                if scrollView.contentOffset.y >= Constants.zero {
                    headerConstraint.constant = -scrollView.contentOffset.y
                    if !isAfterRefresh {
                        collectionView.contentOffset.y = Constants.zero
                    }
                } else {
                    headerConstraint.constant = Constants.zero
                }
                logoHeader?.addMotto(string: ServiceThemeMotto.motto)
            } else if scrollView.contentOffset.y >= maxHeaderOffsetY {
                if headerConstraint.constant != -maxHeaderOffsetY {
                    headerConstraint.constant = -maxHeaderOffsetY
                    logoHeader?.addMotto(string: "")
                }
                collectionView.contentOffset.y = invisibleScrollView.contentOffset.y - maxHeaderOffsetY
            }
            self.view.layoutIfNeeded()
        }
    }
}
