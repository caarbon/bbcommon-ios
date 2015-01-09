Pod::Spec.new do |s|
  s.name                  = "BBCommon"
  s.version               = "0.0.1"
  s.summary               = "Library of UIKit helper macros and classes"
  s.homepage              = "https://github.com/bigbigbomb/bbcommon-ios"
  s.author                = "BigBig Bomb"
  s.source                = { :git => "https://github.com/bigbigbomb/bbcommon-ios.git", :commit => "9ac6788d9b9af6ba7097f4e293189001b5ceebb7" }
  s.source_files          = 'src/BBCommon/BBCommon/**/*.{h,m}','src/BBCommon/MF_Base32Additions/**/*.{h,m}'
  s.requires_arc          = true
  s.ios.frameworks        = 'QuartzCore'
  s.prefix_header_contents = <<-EOS
#import <QuartzCore/QuartzCore.h>
EOS

end
