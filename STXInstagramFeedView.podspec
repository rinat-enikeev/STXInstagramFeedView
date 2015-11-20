Pod::Spec.new do |s|
  s.name             = "STXInstagramFeedView"
  s.version          = "0.1.9"
  s.summary          = "Instagram feed table view."
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

  s.source_files = 'Pod/Classes/**/*.{h,m}'

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
  s.dependency 'Reachability'
  s.dependency 'TSMessages'
  s.dependency 'HexColors'

  s.prefix_header_contents = '#import <UALogger/UALogger.h>', '#import <PureLayout/PureLayout.h>', '#import <TTTAttributedLabel/TTTAttributedLabel.h>', '#import <MHPrettyDate/MHPrettyDate.h>', '#import <InstaModel/InstaModel.h>'
end
