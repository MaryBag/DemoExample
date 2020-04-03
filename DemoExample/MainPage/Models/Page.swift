//
//  Page.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 12/3/19.
//  Copyright © 2019 BM. All rights reserved.
//

import Foundation

struct Page: Codable {
    var data: [PageData]
    var meta: PageMeta
    var links: PageLinks
}

struct PageData: Codable {
    var id: String
    var type: String
    var attributes: PageAttributes
}


struct PageAttributes: Codable {
    var content: Codable?
    var contentType: String
    var images: [Image]

    private enum JSONPageAttributesKeys: String, CodingKey {
        case content
        case styles
        case contentType = "content_type"
        case images
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONPageAttributesKeys.self)
        contentType = try container.decode(String.self, forKey: .contentType)
        images = try container.decode([Image].self, forKey: .images)
        if contentType == "logo" {
            content = try container.decode(LogoContent.self, forKey: .content)
        } else if contentType == "category" {
            content = try container.decode(CategoryContent.self, forKey: .content)
        } else if contentType == "page_link" {
            content = try container.decode(PageLinkContent.self, forKey: .content)
        } else if contentType == "ext_link" {
            content = try container.decode(ExtLinkContent.self, forKey: .content)
        } else if contentType == "text" {
            content = try container.decode(TextContent.self, forKey: .content)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}

struct Image: Codable {
    var imageId: Int
    var imageUrl: String
    
    private enum JSONImageKeys: String, CodingKey {
        case imageId = "image_id"
        case imageUrl = "image_url"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONImageKeys.self)
        imageId = try container.decode(Int.self, forKey: .imageId)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
}

struct LogoContent: Codable {
    var tagline: String
    
    private enum JSONLogoContent: String, CodingKey {
        case tagline
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONLogoContent.self)
        tagline = try container.decode(String.self, forKey: .tagline)
        ServiceThemeMotto.motto = tagline
    }
}

struct CategoryContent: Codable {
    var title: String
    var subtitle: String
    var text: String
    var page: PageType
}

struct PageType: Codable {
    var pageId: String
    var pageType: String
    private enum JSONPageTypeKeys: String, CodingKey {
        case pageId = "page_id"
        case pageType = "category_type"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONPageTypeKeys.self)
        pageId = try container.decode(String.self, forKey: .pageId)
        pageType = try container.decode(String.self, forKey: .pageType)
    }
}

struct PageLinkContent: Codable {
    var url: String
}

struct ExtLinkContent: Codable {
    var url: String
    var description: String
}

struct TextContent: Codable {
    var text: String
}


struct Styles: Codable {
    var color: String
    var bg: String
}

struct PageMeta: Codable {
    var totalPage: Int
    
    private enum JSONPageMetaKey: String, CodingKey {
        case totalPage = "total_page"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONPageMetaKey.self)
        totalPage = try container.decode(Int.self, forKey: .totalPage)
    }
}

struct PageLinks: Codable {
    var prevPage: String
    var selfPage: String
    var nextPage: String
    
    private enum JSONPageLinksKeys: String, CodingKey {
        case prevPage = "previous_page"
        case selfPage = "current_page"
        case nextPage = "next_page"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONPageLinksKeys.self)
        prevPage = try container.decode(String.self, forKey: .prevPage)
        selfPage = try container.decode(String.self, forKey: .selfPage)
        nextPage = try container.decode(String.self, forKey: .nextPage)
    }
}
