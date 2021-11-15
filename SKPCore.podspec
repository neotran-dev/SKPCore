#
# Be sure to run `pod lib lint SKPCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SKPCore'
  s.version          = '0.1.0'
  s.summary          = 'General classes library necessary for most projects iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  SKPCore is a general classes library necessary for most projects iOS.
                       DESC

  s.homepage         = 'https://github.com/neotran-dev/SKPCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lam Tran' => 'lamtran.tech@gmail.com' }
  s.source           = { :git => 'https://github.com/neotran-dev/SKPCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'SKPCore/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SKPCore' => ['SKPCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  #s.static_framework = true
  
  s.dependency 'Alamofire', '~> 5.4'
  s.dependency 'RxSwift', '~> 5.1.2'
  s.dependency 'RxCocoa', '~> 5.1.1'
  s.dependency 'RxDataSources', '~> 4.0.1'
  s.dependency 'NSObject+Rx', '~> 5.1.0'
  s.dependency 'RxSwiftUtilities', '~> 2.2.0'
  s.dependency 'SwiftyJSON', '~> 5.0.1'
  s.dependency "KRProgressHUD", '~> 3.4.7'
  s.dependency 'SnapKit', '~> 5.0'
  s.dependency 'RxSwiftExt', '~> 5.2.0'
  s.dependency 'SwiftEntryKit', '1.2.6'
  
  s.swift_version = "5"
  s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
  
end
