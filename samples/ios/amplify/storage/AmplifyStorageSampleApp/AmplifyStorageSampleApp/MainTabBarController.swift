//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import AWSMobileClient
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 3 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorController)

            present(navController, animated: true, completion: nil)

            return false
        }

        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViewControllers()
    }

    func setupViewControllers() {
        let publicViewController = ItemViewController(collectionViewLayout: UICollectionViewFlowLayout())
        publicViewController.accessLevel = .guest
        let publicNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "globe_unselected"),
                                                        selectedImage: #imageLiteral(resourceName: "globe_selected"),
                                                        title: "Guest",
                                                        rootViewController: publicViewController)


        let protectedViewController = ListUsersViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let protectedNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "lock_unselected"),
                                                           selectedImage: #imageLiteral(resourceName: "lock_selected"),
                                                           title: "Protected",
                                                           rootViewController: protectedViewController)

        let privateViewController = ItemViewController(collectionViewLayout: UICollectionViewFlowLayout())
        privateViewController.accessLevel = .private
        let privateNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "lock_unselected"),
                                                        selectedImage: #imageLiteral(resourceName: "lock_selected"),
                                                        title: "Private",
                                                        rootViewController: privateViewController)

        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "add_unselected"),
                                                      selectedImage: #imageLiteral(resourceName: "add_selected"),
                                                      title: "Upload")

        let profileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"),
                                                        selectedImage: #imageLiteral(resourceName: "profile_selected"),
                                                        title: "Profile",
                                                        rootViewController: ProfileViewController())

        viewControllers = [publicNavController,
                           protectedNavController,
                           privateNavController,
                           plusNavController,
                           profileNavController]

        //modify tab bar item insets
        guard let items = tabBar.items else { return }

        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }


    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, title: String? = nil, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        if let title = title {
            navController.title = title
        }
        return navController
    }
}

