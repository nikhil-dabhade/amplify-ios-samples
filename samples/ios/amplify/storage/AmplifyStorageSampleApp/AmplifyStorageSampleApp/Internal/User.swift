//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

struct User {
    let name: String
    let phoneNumber: String
    let email: String
    init(_ userAttributes: [String: String]) {
        self.email = userAttributes[EmailUserAttributeKey] ?? ""
        self.name = userAttributes[NameUserAttributeKey] ?? ""
        self.phoneNumber = userAttributes[PhoneNumberUserAttributeKey] ?? ""
    }
}
