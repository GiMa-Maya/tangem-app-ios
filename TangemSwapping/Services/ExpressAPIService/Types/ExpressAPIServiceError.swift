//
//  ExpressAPIServiceError.swift
//  TangemSwapping
//
//  Created by Sergey Balashov on 31.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum ExpressAPIServiceError: LocalizedError {
    case requestError(Error)
    case apiError(ExpressDTO.ExpressAPIError)
    case decodingError(Error)

    public var errorDescription: String? {
        switch self {
        case .requestError(let error):
            return error.localizedDescription
        case .apiError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        }
    }
}