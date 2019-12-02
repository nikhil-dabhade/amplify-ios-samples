## Amplify Storage Sample App

This sample app is to showcases the usability of Amplify Storage with AWSMobileClient and storage access levels (public, protected, private).

#### Update local pod directories

Go to the Podfile and update the path to [amplify-ios](https://github.com/aws-amplify/amplify-ios)

#### Install dependencies

If you are trying to install the latest changes from your local pod, make sure to run `pod cache clean --all` to clear the pods for a fresh install, otherwise, run

```bash
pod install
```

#### Open workspace

```bash
open AmplifyStorageSampleApp.xcworkspace
```

#### Generate resources (amplifyconfiguration.json)

1. Run `amplify init` and choose `ios` for the type of app you're building

2. Add auth `amplify add auth` and choose `Default configuration`, allow users to sign in with `Email` and do not configure `advanced settings`

3. Add storage `amplify add storage` 
    * choose `Content (Images, audio, video, etc.)`
    * Who should have access: `Auth and guest users`
    * What kind of access do you want Authenticated users? Select `create/update`, `read`, and `delete`
    * What kind of access do you want Guest users? Select `create/update`, `read`, and `delete`
    * Do you want to add a Lambda Trigger for your S3 Bucket? `No`

4. `amplify push`
s
## Demo

A user that is signed in can choose to upload an image with public/protected/private access. A user that isn't signed in will get AccessDenied when trying to upload to protected or private.

![signedOutUpload](demo_images/signedOutUpload.png)

Files uploaded with public access level can be viewed and deleted by everyone

![public](demo_images/public.png)

Files uploaded with protected access level can be viewed by everyone.

![public](demo_images/protected1.png)
![public](demo_images/protected2.png)

The user can delete their own files.

![public](demo_images/protected3.png)

Files uploaded to private can only be viewed and deleted by that particular user.

![private](demo_images/private.png)


