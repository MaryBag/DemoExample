//
//  PageController+UICollectionViewDelegateFlowLayout.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/15/19.
//  Copyright © 2019 BM. All rights reserved.
//

extension PageController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = CGFloat(2 * Constants.paddingSpace)
        let width = collectionView.bounds.width - paddingSpace
        return CGSize(width: width, height: Constants.boxHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.paddingSpace
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: Constants.footerWidth, height: Constants.footerHeight)
    }
}
