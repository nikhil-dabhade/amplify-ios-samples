//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify

struct Item {
    var key: String
    var accessLevel: StorageAccessLevel
    var targetIdentityId: String?

    init(key: String, accessLevel: StorageAccessLevel, targetIdentityId: String?) {
        self.key = key
        self.accessLevel = accessLevel
        self.targetIdentityId = targetIdentityId
    }
}
