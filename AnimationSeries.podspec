Pod::Spec.new do |spec|

  spec.name         = "AnimationSeries"
  spec.version      = "1.2.0"
  spec.summary      = "Easy way to create a chain of animation."


  spec.description  = <<-DESC
                      Easy way to create a chain of animation. 
                      Animation3 = (Animation1 + Animation2) * 3
                      DESC

  spec.homepage     = "https://github.com/gearmamn06/AnimationSeries"

  spec.license      = { :type => "MIT", :text => <<-LICENSE
    MIT License
Copyright (c) 2019 gearmamn06
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
    LICENSE
  }

  spec.author             = { "gearmamn06" => "gearmamn06@gmail.com" }


  spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "10.0"

  # spec.source       = { :git => "https://github.com/gearmamn06/AnimationSeries.git", :tag => spec.version }

  spec.ios.vendored_frameworks = 'AnimationSeries.framework'
  # spec.source_files  = ["AnimationSeries/Sources/**/*.swift", "AnimationSeries/Sources/AnimationSeries.h"]
  spec.source = { :http => 'https://s3-us-west-2.amazonaws.com/elasticbeanstalk-us-west-2-291822295618/AnimationSeriesFramework.zip'}
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = ["AnimationSeries/Sources/AnimationSeries.h"]
  spec.requires_arc = true

end