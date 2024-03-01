//
//  BackupValidator.swift
//  Tangem
//
//  Created by Alexander Osokin on 21.02.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

struct BackupValidator {
    func validate(_ backupStatus: Card.BackupStatus?) -> Bool {
        guard let backupStatus else {
            return true
        }

        if case .cardLinked = backupStatus {
            return false
        }

        return true
    }
}