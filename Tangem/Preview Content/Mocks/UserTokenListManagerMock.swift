//
//  UserTokenListManagerMock.swift
//  Tangem
//
//  Created by Sergey Balashov on 25.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

struct UserTokenListManagerMock: UserTokenListManager {
    var userTokens: [StorageEntry] { [] }

    var userTokensPublisher: AnyPublisher<[StorageEntry], Never> { .just(output: []) }

    var userTokenList: AnyPublisher<UserTokenList, Never> { .just(output: .empty) }

    func update(with userTokenList: UserTokenList) {}

    func update(_ type: UserTokenListUpdateType, shouldUpload: Bool) {}

    func updateLocalRepositoryFromServer(result: @escaping (Result<Void, Error>) -> Void) {}

    func upload() {}
}
