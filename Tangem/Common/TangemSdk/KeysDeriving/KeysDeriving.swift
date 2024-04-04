//
//  KeysDeriving.swift
//  Tangem
//
//  Created by Alexander Osokin on 04.03.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

typealias DerivationResult = DeriveMultipleWalletPublicKeysTask.Response

protocol KeysDeriving: AnyObject {
    func deriveKeys(derivations: [Data: [DerivationPath]], completion: @escaping (Result<DerivationResult, TangemSdkError>) -> Void)
}
