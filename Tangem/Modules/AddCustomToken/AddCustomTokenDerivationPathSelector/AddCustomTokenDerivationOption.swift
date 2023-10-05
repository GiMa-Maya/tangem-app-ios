//
//  AddCustomTokenDerivationOption.swift
//  Tangem
//
//  Created by Andrey Chukavin on 19.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

enum AddCustomTokenDerivationOption {
    case custom(derivationPath: DerivationPath?)
    case `default`(derivationPath: DerivationPath)
    case blockchain(name: String, derivationPath: DerivationPath)
}

extension AddCustomTokenDerivationOption {
    var id: String {
        switch self {
        case .custom:
            return "custom"
        case .default:
            return "default"
        case .blockchain(let name, _):
            return name
        }
    }

    var name: String {
        switch self {
        case .custom:
            return Localization.customTokenCustomDerivation
        case .default:
            return Localization.customTokenDerivationPathDefault
        case .blockchain(let name, _):
            return name
        }
    }

    var derivationDath: String? {
        switch self {
        case .custom(let derivationPath):
            return derivationPath?.rawPath
        case .default(let derivationPath):
            return derivationPath.rawPath
        case .blockchain(_, let derivationPath):
            return derivationPath.rawPath
        }
    }
}