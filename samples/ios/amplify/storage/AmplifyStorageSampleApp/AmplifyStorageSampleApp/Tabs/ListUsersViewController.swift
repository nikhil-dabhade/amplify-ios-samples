//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import Amplify
import AWSS3
import AmplifyPlugins
class ListUsersViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ProfileCellDelegate {

    let cellId = "cellId"

    var profiles = [Profile]()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateList), name: SharePhotoController.updateProtectedNotificationName, object: nil)

        collectionView?.backgroundColor = .white
        collectionView?.register(ProfileCell.self, forCellWithReuseIdentifier: cellId)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        collectionView?.refreshControl = refreshControl

        setupNavigationItems()

        fetchAllUsers()
    }

    @objc func handleUpdateList() {
        handleRefresh()
    }

    func setupNavigationItems() {
        navigationItem.title = "protected"
    }

    @objc func handleRefresh() {
        print("Handling refresh..")

        fetchAllUsers()
    }

    fileprivate func fetchAllUsers() {

        do {
            // Get Bucket from config
            guard let path = Bundle.main.path(forResource: "amplifyconfiguration", ofType: "json") else {
                print("Could not get amplifyconfiguration.json")
                return
            }
            let url = URL(fileURLWithPath: path)
            let fileData = try Data(contentsOf: url)
            let json = try JSONDecoder().decode(JSONValue.self, from: fileData)
            guard let bucket = json["storage"]?["plugins"]?["awsS3StoragePlugin"]?["bucket"] else {
                print("Could not retrieve bucket from config")
                return
            }
            guard case let .string(bucketValue) = bucket else {
                print("bucket is not a string value")
                return
            }

            // get plugin
            let pluginOptional = try Amplify.Storage.getPlugin(for: "awsS3StoragePlugin")

            guard let plugin = pluginOptional as? AWSS3StoragePlugin else {
                print("Could not cast as AWSS3StoragePlugin")
                return
            }

            let awsS3 = plugin.getEscapeHatch()

            let request: AWSS3ListObjectsV2Request = AWSS3ListObjectsV2Request()

            request.bucket = bucketValue
            request.prefix = "protected/"

            awsS3.listObjectsV2(request).continueWith { (task) -> Any? in
                guard task.error == nil else {
                    let error = task.error! as NSError
                    print("List error", error)
                    return nil
                }

                guard let result = task.result else {
                    print("Missing data")
                    return nil
                }

                print(result)
                self.profiles.removeAll()

                if let contents = result.contents {
                    for content in contents {
                        if let fullKey = content.key {
                            print("fullKey: \(fullKey)")
                            // magic numbers to remove the "protected/" and the "/<keyname>" to get identityId
                            let identityId = String(fullKey.dropFirst(10).dropLast(37))
                            print("IdentityId: \(identityId)")
                            let profile = Profile(identityId: identityId)
                            var alreadyExists = false
                            for profile in self.profiles {
                                if profile.identityId == identityId {
                                    alreadyExists = true
                                }
                            }
                            if !alreadyExists {
                                self.profiles.append(profile)
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.collectionView?.refreshControl?.endRefreshing()
                    self.collectionView?.reloadData()
                }

                return nil
            }

        } catch {
            print("Failed to get AWSS3StoragePlugin")
        }
    }

    // MARK: CollectionView

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileCell

        cell.profile = profiles[indexPath.item]

        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height: CGFloat = 50

        return CGSize(width: view.frame.width, height: height)
    }

    // MARK: Item delegate

    func didTapProfile(profile: Profile) {

        let protectedViewController = ItemViewController(collectionViewLayout: UICollectionViewFlowLayout())
        protectedViewController.accessLevel = .protected
        protectedViewController.targetIdentityId = profile.identityId

        
        navigationController?.pushViewController(protectedViewController, animated: true)

    }
}
