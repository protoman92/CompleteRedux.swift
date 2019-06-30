Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = "9.0"
  s.swift_version = "4.2"
  s.name = "CompleteRedux"
  s.summary = "Rx-enabled Redux implementation for iOS clients."
  s.requires_arc = true
  s.version = "2.0.0"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
  s.homepage = "https://github.com/protoman92/CompleteRedux.git"
  s.source = { :git => "https://github.com/protoman92/CompleteRedux.swift.git", :tag => "#{s.version}"}

  s.subspec "Core" do |ss|
    ss.dependency "SwiftFP/Main"
    ss.source_files = "CompleteRedux/*.{h,swift}", "CompleteRedux/Core/*"
  end

  s.subspec "SimpleStore" do |ss|
    ss.dependency "CompleteRedux/Core"
    ss.source_files = "CompleteRedux/SimpleStore/*"
  end

  s.subspec "UI" do |ss|
    ss.dependency "CompleteRedux/Core"
    ss.source_files = "CompleteRedux/{UI,UI+Test}/*"
  end

  s.subspec "Middleware" do |ss|
    ss.dependency "CompleteRedux/Core"
    ss.source_files = "CompleteRedux/Middleware/*"
  end

  s.subspec "Middleware+Router" do |ss|
    ss.dependency "CompleteRedux/Middleware"
    ss.source_files = "CompleteRedux/Middleware+Router/*"
  end

  s.subspec 'Middleware+Saga' do |ss|
    ss.dependency "RxSwift", '~> 4.0'
    ss.dependency "RxBlocking", '~> 4.0'
    ss.dependency "CompleteRedux/Middleware"
    ss.source_files = "CompleteRedux/Middleware+Saga/*"
  end
end
