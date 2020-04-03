//
//  Pages.swift
//  Module code sample instead of a running project
//
//  Created by Maryia Bahlai on 12/3/19.
//  Copyright © 2019 BM. All rights reserved.
//

import Foundation

struct Pages: Codable {
    var data: [PagesData]
}

struct PagesData: Codable {
    var id: String
    var type: String
    var attributes: PagesAttributes
}

struct PagesAttributes: Codable {
    var customAppId: Int
    var categoryType: String
    
    private enum JSONPagesAttributesKeys: String, CodingKey {
        case customAppId = "custom_app_id"
        case categoryType = "category_type"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONPagesAttributesKeys.self)
        customAppId = try container.decode(Int.self, forKey: .customAppId)
        categoryType = try container.decode(String.self, forKey: .categoryType)
    }
    
}
