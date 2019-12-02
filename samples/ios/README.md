## iOS Samples

## Create a new iOS sample app

#### Create new project

Xcode -> new project -> Single view app -> choose location -> uncheck initializing git option and optionally check UI tests and unit testing targets

#### Initializing PodFile

Go to the project directory and run

```bash
pod init
```

#### Add (local) dependencies

Under the top level target, add your dependencies, for example

```
AWS_SDK_VERSION = "2.10.3"

target 'AmplifyConfigurationApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AmplifyConfigurationApp

  # Adding Amplify from local pod
  pod 'Amplify', :path => '../amplify-ios'

  # Adding plugins from local pod
  # pod 'AWSS3StoragePlugin', :path => '../amplify-ios'

  # Add other dependencies like AWSMobileClient if needed
  # pod "AWSMobileClient", "~> #{AWS_SDK_VERSION}"
  ...
end

```

Make sure the path to your [amplify-ios](https://github.com/aws-amplify/amplify-ios) repository is correct, otherwise you'll get 
```
[!] No podspec found for `Amplify` in `../amplify-ios`
```

#### Install dependencies

```
pod install
```

Close the project that is open, then open using the workspace file 
```
open <Project>.xcworkspace
```

Build the project to find any build issues related to podspec file, like incorrect ios target, missing dependency, etc.

#### Update .gitignore

Add anything that should not be checked in, we don't need to add any more amplify related ones since the CLI will append the rest.

```
amplify
amplifyconfiguration.json

# Pods related
Podfile.lock
Pods

# Xcode generated files #
######################
xcuserdata
*.xccheckout
*.xcscmblueprint
```

#### Documenation

* Run the desired Amplify CLI commands

* Document the required commands to successfully use the sample.

Drag `amplifyconfiguration.json` and `awsconfiguration.json` over to the Xcode, can put it under the top most <Project> target, check 'Copy items if needed', and make sure `AmplifyConfigurationApp' is checked under 'Add to tagets'


