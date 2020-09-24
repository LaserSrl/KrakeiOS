Pod::Spec.new do |s|

    s.name         = "Krake"
    s.version      = "11.3.0"
    s.summary      = "Laser mobile framework."
    s.homepage     = "https://www.laser-group.com"

    s.description  = <<-DESC
    This is a Laser Krake® libraries writted by our devs to integrate Krake® CMS features
    DESC
    s.license      = "MIT"
    s.source       = { :git => "https://github.com/LaserSrl/KrakeiOS.git", :tag => s.version }

    s.authors = { 'Patrick Negretto' => 'patrick.negretto@laser-group.com', 'Joël Gerbore' => 'joel.gerbore@laser-group.com' }

    s.platform = :ios, "11.0"
    s.ios.deployment_target = "11.0"
    s.swift_versions = ['5.0']

    s.requires_arc = true
    s.static_framework = true
    
    s.frameworks  = 'CoreLocation', 'AddressBook', 'AddressBookUI', 'MapKit', 'CoreData', 'WebKit', 'StoreKit'
    
    s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS[config=Debug]' => '-DDEBUG' }
    
    s.default_subspecs = ['Core']
    
    s.subspec 'AppleSignIn' do |os|
        os.frameworks = "AuthenticationServices", "Foundation"
        os.source_files  = "AppleSignIn", "Krake/AppleSignIn/*.swift"
        os.dependency "Krake/Core"
    end
    
    s.subspec 'AppUpdater' do |os|
        os.source_files  = "Krake/AppUpdater/*.{h,m,swift}"
        os.dependency "Krake/Commons"
    end

    s.subspec 'Beacons' do |os|
        os.source_files  = "Krake/Beacons/*.{swift}"
        os.dependency "Krake/Core"
    end
    
    s.subspec 'Braintree' do |os|
        os.source_files  = "Krake/Braintree/*.{swift}"
        os.dependency "Krake/Core"
        os.dependency "Braintree", '4.35.0'
    end
    
    s.subspec 'Commons' do |os|
        os.source_files  = "Krake/Commons/*.{swift}"
    end
    
    s.subspec 'ContentManager' do |os|
        os.source_files  = "Krake/ContentManager/**/*.{h,m,swift}"
        os.ios.resource_bundle = { 'ContentManager' => ['Krake/ContentManager/**/*.{storyboard,xib}']}
        os.dependency "Krake/Core"
        os.dependency "FDTake", '3.0.0'
        os.dependency "LaserPicker", '1.0.0'
        os.dependency "IQAudioRecorderController", '1.2.3'
    end
    
    s.subspec 'Core' do |os|
        os.source_files  = ['Krake/Core/*.{h,m,swift}', 'Krake/Krake.h', 'Krake/Mapper/**/*.{h,m,swift}', 'Krake/Content/**/*.{h,m,swift}', 'Krake/Extentions/*.{h,m,swift}', 'Krake/Mappe/*.{h,m,swift}', 'Krake/Analytics/*.{h,m,swift}', 'Krake/Localization/*.{swift}']
        os.ios.resource_bundles = { 'OrchardGen' => ['Krake/Mapper/OGLMapperConfiguration.plist'], 'LoginManager' => ['Krake/Mapper/LoginManager/*.storyboard'], 'PrivacyManager' => ['Krake/Mapper/PrivacyManager/*.storyboard'], 'Content' => ['Krake/Content/**/*.{xib,storyboard}'], 'Core' => ['Krake/Core/**/*.{xib}'],  'Location' => ['Krake/Mappe/*.storyboard'], 'Localization' => ['Krake/Localization/*.{lproj}'], 'KrakeImages' => ['Krake/*.{xcassets}', 'Krake/Mapper/**/*.{xcassets}'] }

        os.dependency "Krake/Commons"
        
        #other
        os.dependency 'Alamofire', '~> 5.2.2'
        os.dependency 'AlamofireNetworkActivityIndicator', '~> 3.1.0'
        os.dependency "CryptoSwift", '1.3.2'
        os.dependency "Firebase", '~> 6.32.0'
        os.dependency "FirebaseCrashlytics"
        os.dependency "Firebase/Messaging"
        os.dependency "KNSemiModalViewController_hons82", '0.4.6'
        os.dependency "libPhoneNumber-iOS", '~> 0.9.15'
        os.dependency "MBProgressHUD", '1.2.0'
        os.dependency "NTPKit", '1.0.1'
        os.dependency "SDWebImage", '~> 5.9.1'
        os.dependency "SwiftyJSON", '5.0.0'
        os.dependency "SwiftMessages", '~> 8.0.2'
        os.dependency "Cluster", '~> 3.0.3'
        os.dependency "Kml.swift", '0.3.2'
        os.dependency "Segmentio", '~> 4.1'

        os.dependency "LaserWebViewController", '2.0.1'
        os.dependency "LaserFloatingTextField", '1.0.0'
        os.dependency "LaserVideoPhotoGallery", '3.0.3'
        os.dependency "LaserSwippableCell", '1.0.0'
        os.dependency "LaserCalendarTimeSelector", '1.5.3'
    end
    
    s.subspec 'FacebookKit' do |os|
        os.source_files  = "FacebookKit", "Krake/FacebookKit/*.{h,m,swift}"
        os.dependency "Krake/Core"
        os.dependency "FBSDKCoreKit", '~> 7.1.1'
        os.dependency "FBSDKLoginKit", '~> 7.1.1'
    end
    
    s.subspec 'GameQuiz' do |os|
        os.source_files  = "GameQuiz", "Krake/GameQuiz/**/*.{h,m,swift}"
        os.ios.resource_bundles = {'GameQuiz' => ['Krake/GameQuiz/*.{storyboard,xcassets}']}
        os.dependency "Krake/Core"
    end
    
    s.subspec 'GoogleKit' do |os|
        os.source_files  = "GoogleKit", "Krake/GoogleKit/*.{swift}"
        os.dependency "Krake/Core"
#TODO: - da aggiornare alla 5.x ma richiede un intervento sui delegate!
        os.dependency "GoogleSignIn", '4.4.0'
    end
    
    s.subspec 'InstagramKit' do |os|
        os.source_files  = "InstagramKit", "Krake/InstagramKit/*.{swift}"
        os.ios.resource_bundles = { 'InstagramKit' => ['Krake/InstagramKit/*.xcassets']}
        os.dependency "Krake/Core"
        os.dependency "Krake/OAuth"
    end
    
    s.subspec 'LinkedInKit' do |os|
        os.source_files  = "LinkedInKit", "Krake/LinkedInKit/*.{swift}"
        os.dependency "Krake/Core"
        os.dependency "Krake/OAuth"
    end
    
    s.subspec 'OAuth' do |os|
        os.source_files  = "OAuth", "Krake/OAuth/*.{swift}"
        os.ios.resource_bundles = {'OAuth' => ['Krake/OAuth/*.storyboard']}
        os.dependency "Krake/Commons"
        os.dependency "MBProgressHUD", '1.2.0'
    end
    
    s.subspec 'OTP' do |os|
        os.source_files  = "OTP", "Krake/OTP/**/*.{h,m,swift}"
        os.frameworks  = "MapKit"
        os.ios.resource_bundles = { 'OTP' => ['Krake/OTP/*.{storyboard,xcassets}']}
        os.dependency "Krake/Core"
        os.dependency "Polyline", '4.2.1'
        os.dependency "DateTimePicker", '~> 2.4.1'
        os.dependency "EVReflection", '5.10.1'
    end
    
    s.subspec 'Policies' do |os|
        os.source_files  = "Krake/Policies/*.{h,m,swift}"
        os.ios.resource_bundles = { 'Policies' => ['Krake/Policies/*.storyboard']}
        os.dependency "Krake/Core"
    end

    s.subspec 'PostCard' do |os|
        os.source_files  = "Krake/PostCard/*.{h,m,swift}"
        os.ios.resource_bundles = { 'PostCard' => ['Krake/PostCard/*.storyboard']}
        os.dependency "Krake/Core"
    end
    
    s.subspec 'PuzzleGame' do |os|
        os.source_files  = "PuzzleGame", "Krake/PuzzleGame/**/*.{swift}"
        os.ios.resource_bundles = {'PuzzleGame' => ['Krake/PuzzleGame/*.{storyboard,xcassets}']}
        os.dependency "Krake/Core"
    end
    
    s.subspec 'Questionnaires' do |os|
        os.source_files  = "Questionnaires", "Krake/Questionnaires/*.swift"
        os.ios.resource_bundles = {'Questionnaires' => ['Krake/Questionnaires/**/*.{storyboard,xib}']}
        os.dependency "Krake/Core"
    end
    
    s.subspec 'Reportages' do |os|
        os.source_files  = "Reportages", "Krake/Reportages/*.swift"
        os.ios.resource_bundles = {'Reportages' => ['Krake/Reportages/*.{storyboard,xib}']}
        os.dependency "Krake/ContentManager"
        os.dependency "Krake/Core"
    end
    
    s.subspec 'TwitterKit' do |os|
        os.source_files  = "TwitterKit", "Krake/TwitterKit/*.{h,m,swift}"
        os.dependency "Krake/Core"
        os.dependency "TwitterKit", '3.4.2'
    end
    
    #s.subspec 'Vimeo' do |os|
        #os.source_files = "Krake/Vimeo/*.{swift}"
        #os.dependency "Krake/Core"
    #end

end
