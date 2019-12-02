//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum ConfirmCodeSource {
    case forgotPassword(username: String)
    case confirmSignUp(username: String, password: String)
}
