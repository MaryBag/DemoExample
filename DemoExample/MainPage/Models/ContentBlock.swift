//
//  HeaderModel.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 12/16/19.
//  Copyright © 2019 BM. All rights reserved.
//

import Foundation

struct ContentBlock {
    var title: String
    var subtitle: String
    var description: String
    var id: String
    var pageType: String
    var urls: [String]
    
    func equals(to content: ContentBlock) -> Bool {
        return self.title == content.title && self.subtitle == content.subtitle && self.description == content.description && self.id == content.id && self.pageType == content.pageType && self.urls == content.urls
    }
}
