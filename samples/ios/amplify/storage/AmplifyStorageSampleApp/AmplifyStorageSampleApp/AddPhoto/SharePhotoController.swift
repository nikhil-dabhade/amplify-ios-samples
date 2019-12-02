//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import Amplify

class SharePhotoController: UIViewController {

    static let updatePublicNotificationName = NSNotification.Name(rawValue: "UpdatePublicFeed")
    static let updateProtectedNotificationName = NSNotification.Name(rawValue: "UpdateProtectedFeed")
    static let updatePrivateNotificationName = NSNotification.Name(rawValue: "UpdatePrivateFeed")

    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()

    let segmentedControl: UISegmentedControl = {
        let items = ["guest", "protected", "private"]
        let sc = UISegmentedControl(items: items)
        sc.layer.cornerRadius = 5.0
        sc.selectedSegmentIndex = 0
        return sc
    }()

    let progressView: UIProgressView = {
        let pv = UIProgressView()
        pv.trackTintColor = UIColor.lightGray
        pv.tintColor = UIColor.blue
        return pv
    }()

    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        containerView.addSubview(imageView)
        // TODO: add others to containerView

        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)

        view.addSubview(segmentedControl)
        segmentedControl.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)

        view.addSubview(progressView)
        progressView.anchor(top: segmentedControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 10)

        view.addSubview(errorMessageLabel)
        errorMessageLabel.anchor(top: progressView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    }
    
    @objc func handleShare() {
        guard let image = selectedImage else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false

        let filename = NSUUID().uuidString

        let accessLevel = StorageAccessLevel.init(rawValue: segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!)
        let options = StorageUploadDataOperation.Request.Options(accessLevel: accessLevel!)

        var storageUploadDataOperation: StorageUploadDataOperation?
        storageUploadDataOperation = Amplify.Storage.uploadData(key: filename, data: uploadData, options: options) { (event) in
            switch event {
            case .completed(let completed):
                print("completed \(completed)")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)

                    switch options.accessLevel {
                    case .guest:
                        NotificationCenter.default.post(name: SharePhotoController.updatePublicNotificationName, object: nil)
                    case .protected:
                        NotificationCenter.default.post(name: SharePhotoController.updateProtectedNotificationName, object: nil)
                    case .private:
                        NotificationCenter.default.post(name: SharePhotoController.updatePrivateNotificationName, object: nil)
                    }

                }

                storageUploadDataOperation?.removeListener()
                break
            case .failed(let storagePutError):
                print("failed: \(storagePutError)")
                DispatchQueue.main.async {
                    let errorDescription: String = storagePutError.errorDescription
                    self.errorMessageLabel.text = "\(errorDescription)"
                }
                storageUploadDataOperation?.removeListener()
                break
            case .inProcess(let progress):
                print("progress: \(progress)")
                DispatchQueue.main.async {
                    self.progressView.progress = Float(progress.fractionCompleted)
                }

            default:
                break
            }
        }
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }
}
