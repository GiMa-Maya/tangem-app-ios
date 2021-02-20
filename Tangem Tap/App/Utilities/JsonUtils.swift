//
//  JsonUtils.swift
//  Tangem Tap
//
//  Created by Andrew Son on 16/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

struct JsonUtils {
    
    static func readBundleFile<T: Decodable>(with name: String, type: T.Type, shouldAddCompilationCondition: Bool = true) throws -> T {
        var suffix: String = ""
        if shouldAddCompilationCondition {
            #if DEBUG
            suffix = "_dev"
            #else
            suffix = "_prod"
            #endif
        }
        guard let path = Bundle.main.url(forResource: name + suffix, withExtension: "json") else {
            throw NSError(domain: "Failed to find json file with name: \(name)", code: -9999, userInfo: nil)
        }
        
        return try readJsonData(Data(contentsOf: path), type: type)
    }
    
    static func readJsonData<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        let jsonDecorer = JSONDecoder()
        return try jsonDecorer.decode(type, from: data)
    }
    
    static func writeJsonToData<T: Encodable>(_ info: T) throws -> Data {
        let jsonEncoder = JSONEncoder()
        return try jsonEncoder.encode(info)
    }
    
}
