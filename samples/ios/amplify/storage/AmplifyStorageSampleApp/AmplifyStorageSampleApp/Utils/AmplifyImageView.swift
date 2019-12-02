//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import Amplify

var imageCache = [String: UIImage]()

class AmplifyImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(key: String, accessLevel: StorageAccessLevel, identityId: String?) {
        lastURLUsedToLoadImage = key
        
        self.image = nil
        
        if let cachedImage = imageCache[key] {
            self.image = cachedImage
            return
        }

        let options = StorageDownloadDataRequest.Options(accessLevel: accessLevel, targetIdentityId: identityId)
        var storageDownloadDataOperation: StorageDownloadDataOperation?
        storageDownloadDataOperation = Amplify.Storage.downloadData(key: key, options: options) { (event) in
            switch event {
            case .failed(let error):
                print("Failed \(error)")
                storageDownloadDataOperation?.removeListener()
            case .completed(let data):
                print("completed \(data)")
                let photoImage = UIImage(data: data)
                imageCache[key] = photoImage
                DispatchQueue.main.async {
                    self.image = photoImage
                }

                storageDownloadDataOperation?.removeListener()
            default:
                break
            }
        }
    }
}
