
Pod::Spec.new do |spec|

  spec.name         = "AnimationSeries"
  spec.version      = "1.0.0"
  spec.summary      = "Easy way to create a chain of animation."


  spec.description  = <<-DESC
                      Easy way to create a chain of animation. 
                      Animation3 = (Animation1 + Animation2) * 3
                      DESC

  spec.homepage     = "https://github.com/gearmamn06/AnimationSeries"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "gearmamn06" => "gearmamn06@gmail.com" }


  spec.swift_version = "4.2"
  spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "10.0"

  spec.source       = { :git => "https://github.com/gearmamn06/AnimationSeries.git", :tag => spec.version }


  spec.source_files  = ["AnimationSeries/Sources/**/*.swift", "AnimationSeries/Sources/AnimationSeries.h"]
  # spec.exclude_files = "Classes/Exclude"
  spec.public_header_files = ["AnimationSeries/Sources/AnimationSeries.h"]
  spec.requires_arc = true

end
