#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'facebook_app_events'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Facebook Analytics and App Events'
  s.description      = <<-DESC
Flutter plugin for Facebook Analytics and App Events
                       DESC
  s.homepage         = 'https://github.com/oddbit/flutter_facebook_app_events'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Oddbit Team' => 'flutter@oddbit.id' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit', '~> 5.5'
  
  # https://github.com/flutter/flutter/issues/14161
  s.static_framework = true
  
  s.ios.deployment_target = '9.0'
end

