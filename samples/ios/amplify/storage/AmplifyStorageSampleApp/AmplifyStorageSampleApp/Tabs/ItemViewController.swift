//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import Amplify

class ItemViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ItemCellDelegate {

    var accessLevel: StorageAccessLevel?
    var targetIdentityId: String?
    let cellId = "cellId"
    var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        collectionView?.register(ItemCell.self, forCellWithReuseIdentifier: cellId)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        collectionView?.refreshControl = refreshControl

        setupNavigationItems()
        setupNotifcations()

        fetchAllItems()

    }

    func setupNotifcations() {
        if let accessLevel = accessLevel {
            switch accessLevel {
            case .guest:
                NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updatePublicNotificationName, object: nil)
            case .protected:
                NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateProtectedNotificationName, object: nil)
            case .private:
                NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updatePrivateNotificationName, object: nil)
            }
        }
    }
    @objc func handleUpdateFeed() {
        handleRefresh()
    }

    func setupNavigationItems() {
        if let accessLevel = accessLevel {
            navigationItem.title = accessLevel.rawValue
        } else {
            navigationItem.title = "guest"
        }
    }


    fileprivate func fetchAllItems() {

        let options = StorageListRequest.Options(accessLevel: accessLevel ?? .guest, targetIdentityId: targetIdentityId)
        var storageListOperation: StorageListOperation?
        storageListOperation = Amplify.Storage.list(options: options, listener: { (event) in
            switch event {
            case .completed(let completed):
                print("completed \(completed)")

                DispatchQueue.main.async {

                    self.items.removeAll()
                    for item in completed.items {
                        self.items.append(Item(key: item.key, accessLevel: self.accessLevel ?? .guest, targetIdentityId: self.targetIdentityId))
                    }
                    self.collectionView?.refreshControl?.endRefreshing()
                    self.collectionView?.reloadData()
                }

                storageListOperation?.removeListener()
            case .failed(let failed):
                print("Failed \(failed)")
                storageListOperation?.removeListener()
            default:
                break
            }
        })
    }

    @objc func handleRefresh() {
       print("Handling refresh..")

       fetchAllItems()
   }

    // MARK: CollectionView

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ItemCell

        cell.item = items[indexPath.item]

        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 50 // header
        height += view.frame.width
        height += 10 // footer

        return CGSize(width: view.frame.width, height: height)
    }

    // MARK: Item delegate

    func didTapDelete(item: Item) {
        print("deleting item with key \(item.key)")
        var storageRemoveOperation: StorageRemoveOperation?

        let options = StorageRemoveRequest.Options(accessLevel: accessLevel ?? .guest)
        storageRemoveOperation = Amplify.Storage.remove(key: item.key, options: options) { (event) in
            switch event {
            case .completed(let completed):
                print("completed \(completed)")
                self.fetchAllItems()
                switch options.accessLevel {
                case .guest:
                    NotificationCenter.default.post(name: SharePhotoController.updatePublicNotificationName, object: nil)
                case .protected:
                    NotificationCenter.default.post(name: SharePhotoController.updateProtectedNotificationName, object: nil)
                case .private:
                    NotificationCenter.default.post(name: SharePhotoController.updatePrivateNotificationName, object: nil)
                }
                storageRemoveOperation?.removeListener()
            case .failed(let error):
                print("failed \(error)")
                storageRemoveOperation?.removeListener()
            default:
                break
            }

        }
    }
}
