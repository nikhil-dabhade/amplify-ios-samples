//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import AWSMobileClient

protocol ItemCellDelegate {
    func didTapDelete(item: Item)
}

class ItemCell: UICollectionViewCell {
    var delegate: ItemCellDelegate?

    var item: Item? {
        didSet {
            guard let key = item?.key else { return }
            guard let accessLevel = item?.accessLevel else { return }

            keyLabel.text = key
            
            switch accessLevel {
            case .guest:
                userLabel.text = "N/A"
            case .protected:
                userLabel.text = item?.targetIdentityId

                if let targetIdentity = item?.targetIdentityId, let identityId = AWSMobileClient.default().identityId {
                    if targetIdentity != identityId {
                        deleteButton.isHidden = true
                    }
                }
            case .private:
                userLabel.text = AWSMobileClient.default().identityId
            }

            amplifyImageView.loadImage(key: key, accessLevel: accessLevel, identityId: item?.targetIdentityId)


        }
    }

    let userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    let keyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "delete").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()

    let amplifyImageView: AmplifyImageView = {
        let iv = AmplifyImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    @objc func handleDelete() {
        print("Deleting item")
        guard let item = item else { return }
        
        delegate?.didTapDelete(item: item)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(userLabel)
        addSubview(keyLabel)
        addSubview(deleteButton)
        addSubview(amplifyImageView)

        userLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
        keyLabel.anchor(top: userLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        deleteButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 30)
        amplifyImageView.anchor(top: keyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        amplifyImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
