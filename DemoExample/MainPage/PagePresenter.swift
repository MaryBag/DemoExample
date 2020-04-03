//
//  PagePresenter.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 11/15/19.
//  Copyright © 2019 BM. All rights reserved.
//

import Foundation
import Resolver
import BoltsSwift

protocol PagePresenterProtocol {
    var nextPage: String? { get }
    var isLoadingList: Bool { get }
    var prevCount: Int { get }
    func setContentForCell(cell: CategoryBox, id: Int)
    func viewDidLoad(completion: @escaping ((Bool)->()))
    func getCount() -> Int
    func didSelectCell(id: Int)
    func makeRequestToNextPage(completion: @escaping ((Bool)->()))
    func getLogo() -> LogoContainerProtocol
    func refresh(completion: @escaping ((Bool)->()))
    func getErrorController(controller: UIViewController?, error: Error?) -> ErrorPopUPControllerProtocol
    func logout()
}

class PagePresenter: PagePresenterProtocol {
    weak var controller: PageControllerProtocol?
    var attributes: [ContentBlock] = []
    var nextPage: String?
    var isLoadingList = false
    var pageSize = 5
    var prevCount: Int = 0
    
    func refresh(completion: @escaping ((Bool)->())) {
        self.prevCount = 0
        makeRequestToFirstPage(isRefreshing: true, completion: completion)
    }
    
    func viewDidLoad(completion: @escaping ((Bool)->())) {
        isLoadingList = true
        makeRequestToFirstPage(isRefreshing: false,completion: completion)
    }
    
    func makeRequestToNextPage(completion: @escaping ((Bool)->())) {
        prevCount = attributes.count
        guard let nextPage = self.nextPage else { return }
        if nextPage != "" && !isLoadingList {
            isLoadingList = true
            let service: ServiceProtocol = Resolver.service.resolve()
            let task: Task<Page> = service.getNextPageTask(nextPage: nextPage)
            task.continueOnSuccessWith{ (page) in
                self.continueOnSuccessTask(page: page, completion: completion)
            }.continueOnErrorWith { (error) in
                DispatchQueue.main.async {
                    self.continueOnErrorTask(error: error)
                }
            }
        }
    }
    
    func setContentForCell(cell: CategoryBox, id: Int) {
        if attributes.count > id {
            cell.clean()
            cell.activity.startAnimating()
            var presenter: CategoryBoxPresenterProtocol = Resolver.ui.resolve()
            cell.presenter = presenter
            presenter.view = cell
            cell.presenter?.addContent(content: attributes[id])
        }
    }
    
    func getCount() -> Int {
        return attributes.count
    }
    
    func didSelectCell(id: Int) {
        if attributes.count > id {
            if attributes[id].pageType == "subcategory" {
                let categoryPrecenter: CategoryPagePresenterProtocol = Resolver.ui.resolve(args: attributes[id])
                let categoryPage: CategoryPage = Resolver.ui.resolve(args: categoryPrecenter)
                guard let controller = categoryPage.controller else { return }
                self.controller?.controller?.navigationController?.pushViewController(controller, animated: true)
            } else if attributes[id].pageType == "detail" {
                let contentPresenter: ContentPagePresenterProtocol = Resolver.ui.resolve(args: attributes[id])
                let contentPage: ContentPage = Resolver.ui.resolve(args: contentPresenter)
                guard let newController = contentPage.controller else { return }
                self.controller?.controller?.navigationController?.pushViewController(newController, animated: true)
            }
        }
    }
    
    func getLogo() -> LogoContainerProtocol {
        let logo: LogoContainerProtocol = Resolver.ui.resolve()
        return logo
    }
    
    func getErrorController(controller: UIViewController?, error: Error?) -> ErrorPopUPControllerProtocol {
        let errorController: ErrorPopUPController = Resolver.ui.resolve(args: (controller, error))
        return errorController
    }
    
    func logout() {
        let service: Service = Resolver.service.resolve()
        let task: Task<AccessToken> = service.getLogOutTask()
        task.continueOnSuccessWith { (user) in
            DispatchQueue.main.async {
                let controller: LogInViewController = Resolver.ui.resolve()
                guard let newController = controller.controller else { return }
                self.controller?.controller?.navigationController?.pushViewController(newController, animated: true)
            }
        }.continueOnErrorWith { (error) in
            DispatchQueue.main.async {
                self.continueOnErrorTask(error: error)
            }
        }
    }
    
}

private extension PagePresenter {
    
    func makeRequestToFirstPage(isRefreshing: Bool, completion: @escaping ((Bool)->())) {
        let service: ServiceProtocol = Resolver.service.resolve()
        let task: Task<Pages> = service.getMainPageTask()
        task.continueOnSuccessWithTask { (pages) -> Task<Page> in
            if pages.data.count > 0 {
                return service.getTask(pageId: pages.data[0].id, pageSize: String(self.pageSize))
            } else {
                let src = TaskCompletionSource<Page>()
                let error = NetworkError.serverError
                src.set(error: error)
                return src.task
            }
        }.continueOnSuccessWith { (page)  in
            DispatchQueue.main.async {
                if isRefreshing {
                    self.refreshOnSuccessTask(page: page, completion: completion)
                } else {
                    self.continueOnSuccessTask(page: page, completion: completion)
                }
            }
        }.continueOnErrorWith { (error) in
            DispatchQueue.main.async {
                self.continueOnErrorTask(error: error) 
            }
        }
    }
    
    func continueOnErrorTask(error: Error) {
        self.controller?.showError(error)
    }
    
    func continueOnSuccessTask(page: Page, completion: @escaping ((Bool)->())) {
        for block in page.data {
            if block.attributes.contentType == "category" {
                DispatchQueue.main.async {
                    guard let content = self.createContent(attributes: block.attributes) else { return }
                    if content.id != "" {
                        self.attributes.append(content)
                    }
                }
            }
        }
        completion(true)
        self.nextPage = page.links.nextPage
        self.isLoadingList = false
    }
    
    func refreshOnSuccessTask(page: Page, completion: @escaping ((Bool)->())) {
        guard self.attributes.count >= 0 else {return}
        var counter = 0
        for block in page.data {
            if block.attributes.contentType == "category" {
                guard let categoryContent = block.attributes.content as? CategoryContent else { return }
                 guard let content = self.createContent(attributes: block.attributes) else { return }
                if self.attributes.count > counter && categoryContent.page.pageId != "" {
                    if self.attributes[counter].id == categoryContent.page.pageId {
                        self.attributes[counter] = content
                    } else {
                        self.attributes.insert(content, at: counter)
                    }
                    counter += 1
                } else if categoryContent.page.pageId != "" {
                    self.attributes.insert(content, at: counter)
                    counter += 1
                }
            }
        }
        while self.attributes.count != counter {
            self.attributes.removeLast()
        }
        completion(true)
        self.nextPage = page.links.nextPage
        self.isLoadingList = false
    }
    
    func createContent(attributes: PageAttributes) -> ContentBlock? {
        guard let categoryContent = attributes.content as? CategoryContent else { return nil }
        var urls: [String] = []
        for image in attributes.images {
            urls.append(image.imageUrl)
        }
        return ContentBlock(title: categoryContent.title, subtitle: categoryContent.subtitle, description: categoryContent.text, id: categoryContent.page.pageId, pageType: categoryContent.page.pageType, urls: urls)
    }
    
    func getCompletion(checker: Bool, completion: @escaping (Bool)->()) {
        completion(checker)
    }
}
