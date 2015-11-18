#
# Be sure to run `pod lib lint STXInstagramFeedView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "STXInstagramFeedView"
  s.version          = "0.1.2"
  s.summary          = "Instagram feed table view."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        STXInstagramFeedView displays instagram posts as in the original app.
                       DESC

  s.homepage         = "https://github.com/rinat-enikeev/STXInstagramFeedView.git"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Rinat Enikeev" => "rinat.enikeev@gmail.com" }
  s.source           = { :git => "https://github.com/rinat-enikeev/STXInstagramFeedView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'STXInstagramFeedView' => ['Pod/Classes/**/*.xib']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'TTTAttributedLabel'
  s.dependency 'PureLayout'
  s.dependency 'MHPrettyDate'
  s.dependency 'UALogger'
  s.dependency 'InstaModel'

  s.prefix_header_contents = '#import <UALogger/UALogger.h>', '#import <PureLayout/PureLayout.h>', '#import <TTTAttributedLabel/TTTAttributedLabel.h>', '#import <MHPrettyDate/MHPrettyDate.h>', '#import <InstaModel/InstaModel.h>'
end
