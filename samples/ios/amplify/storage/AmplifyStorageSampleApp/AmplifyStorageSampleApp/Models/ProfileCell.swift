//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit

protocol ProfileCellDelegate {
    func didTapProfile(profile: Profile)
}

class ProfileCell: UICollectionViewCell {
    var delegate: ProfileCellDelegate?

    var profile: Profile? {
        didSet {
            guard let identityId = profile?.identityId else { return }

            profileButton.setTitle(identityId, for: .normal)

        }
    }

    lazy var profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleProfileTapped), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileButton)
        profileButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleProfileTapped() {

        guard let profile = profile else { return }

        delegate?.didTapProfile(profile: profile)
    }
}
