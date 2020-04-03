//
//  CategoryBoxPresenter.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 12/5/19.
//  Copyright © 2019 BM. All rights reserved.
//

import Foundation
import Resolver

protocol CategoryBoxPresenterProtocol {
    func addContent(content: ContentBlock?)
    var view: CategoryBox? {get set}
    var content: ContentBlock? { get }
}

class CategoryBoxPresenter: CategoryBoxPresenterProtocol {
    weak var view: CategoryBox?
    var urlContent: String?
    var content: ContentBlock?
    
    func addContent(content: ContentBlock?) {
        self.content = content
        view?.clean()
        guard let content = content else { return }
        view?.navigationItem()
        view?.setTitle(text: content.title)
        view?.setSubtile(text: content.subtitle)
        view?.setDescription(text: content.description)
        if content.urls.count != 0 {
            self.downloadImage(url: content.urls[0])
        } else if let url = ServiceThemeImages.defaultImage {
            self.downloadImage(url: url)
        }
    }
    
}

private extension CategoryBoxPresenter {
    func downloadImage(url: String) {
        urlContent = url
        let service:ImageServiceProtocol = Resolver.service.resolve()
        service.download(url: url) { [weak self] (url, image, error) in
            guard let self = self else { return }
            if url == self.urlContent {
                if let image = image {
                    DispatchQueue.main.async {
                        self.view?.addImage(image: image)
                        self.view?.updateFocusIfNeeded()
                    }
                } else if let _ = error {
                    DispatchQueue.main.async {
                        guard let urlDefaltImage = ServiceThemeImages.defaultImage else { return }
                        service.download(url: urlDefaltImage) { [weak self] (url, image, error) in
                            guard let self = self else { return }
                            if let image = image {
                                DispatchQueue.main.async {
                                    self.view?.addImage(image: image)
                                    self.view?.updateFocusIfNeeded()
                                }
                            } else if let _ = error, let defaultImage = UIImage(named: "image") {
                                DispatchQueue.main.async {
                                    self.view?.addImage(image: defaultImage)
                                    self.view?.updateFocusIfNeeded()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
