# Uncomment the next line to define a global platform for your project
platform :ios, '14.4'

target 'FoodTrack' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Firebase pods
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'FirebaseFirestoreSwift'

#pod 'FirebaseUI/Google'
#pod 'FirebaseUI/Facebook'
#pod 'FirebaseUI/OAuth'  # Used for Sign in with Apple, Twitter, etc
#pod 'FirebaseUI/Phone'

  # Other pods
pod 'SwipeCellKit'
pod 'IQKeyboardManagerSwift'

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.4'
      end
    end
end

end




target 'FoodTrackTests' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Firebase pods
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'FirebaseFirestoreSwift'

#pod 'FirebaseUI/Google'
#pod 'FirebaseUI/Facebook'
#pod 'FirebaseUI/OAuth'  # Used for Sign in with Apple, Twitter, etc
#pod 'FirebaseUI/Phone'

  # Other pods
pod 'SwipeCellKit'
pod 'IQKeyboardManagerSwift'

end
