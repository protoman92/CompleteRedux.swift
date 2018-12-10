Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = "9.0"
  s.swift_version = "4.2"
  s.name = "ReactiveRedux"
  s.summary = "Rx-enabled Redux implementation for iOS clients."
  s.requires_arc = true
  s.version = "1.0.1"
  s.license = { :type => "Apache-2.0", :file => "LICENSE" }
  s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
  s.homepage = "https://github.com/protoman92/ReactiveRedux-Swift.git"
  s.source = { :git => "https://github.com/protoman92/ReactiveRedux-Swift.git", :tag => "#{s.version}"}

  s.subspec "Main" do |ss|
    ss.dependency "SwiftFP/Main"
    ss.source_files = "ReactiveRedux/*.{h,swift}", "ReactiveRedux/Preset/*", "ReactiveRedux/Store/*"
  end

  s.subspec "Rx" do |ss|
    ss.dependency "RxSwift"
    ss.dependency "ReactiveRedux/Main"
    ss.source_files = "ReactiveRedux/RxStore/*.{swift}"
  end

  s.subspec "UI" do |ss|
    ss.dependency "ReactiveRedux/Main"
    ss.source_files = "ReactiveRedux/UI/*"
  end

  s.subspec "Middleware" do |ss|
    ss.dependency "ReactiveRedux/Main"
    ss.source_files = "ReactiveRedux/Middleware/*"
  end

  s.subspec "Middleware+Router" do |ss|
    ss.dependency "ReactiveRedux/Middleware"
    ss.source_files = "ReactiveRedux/Middleware+Router/*"
  end

  s.subspec 'Middleware+Saga' do |ss|
    ss.dependency "RxSwift"
    ss.dependency "ReactiveRedux/Middleware"
    ss.source_files = "ReactiveRedux/Middleware+Saga/*"
  end

  s.subspec "UI+Test" do |ss|
    ss.dependency "ReactiveRedux/UI"
    ss.source_files = "ReactiveRedux/UI+Test/*"
  end
end
