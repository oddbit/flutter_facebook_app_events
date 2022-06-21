Pod::Spec.new do |s|
  s.name             = 'facebook_app_events'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Facebook Analytics and App Events'
  s.description      = <<-DESC
Flutter plugin for Facebook Analytics and App Events
                       DESC
  s.homepage         = 'https://github.com/oddbit/flutter_facebook_app_events'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Oddbit Team' => 'opensource@oddbit.id' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit', '~> 14.0.0'
  s.dependency 'FBAudienceNetwork', '~> 6.9.0'
  s.swift_version       = '5.0'

  s.ios.deployment_target = '11.0'
end
