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
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit', '~> 9.0.0'
  s.swift_version       = '4.0'

  s.ios.deployment_target = '9.0'
end
