Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = "9.0"
  s.swift_version = "4.2"
  s.name = "ReactiveRedux"
  s.summary = "Rx-enabled Redux implementation for iOS clients."
  s.requires_arc = true
  s.version = "1.0.0"
  s.license = { :type => "Apache-2.0", :file => "LICENSE" }
  s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
  s.homepage = "https://github.com/protoman92/ReactiveRedux-Swift.git"
  s.source = { :git => "https://github.com/protoman92/ReactiveRedux-Swift.git", :tag => "#{s.version}"}
  s.dependency "SwiftFP/Main"

  s.subspec "Main" do |m|
    m.source_files = "ReactiveRedux/*.{h,swift}", "ReactiveRedux/Preset/*"
  end

  s.subspec "Rx" do |mrx|
    mrx.dependency "RxSwift"
    mrx.dependency "ReactiveRedux/Main"
    mrx.source_files = "ReactiveRedux/RxStore/*.{swift}"
  end

  s.subspec "UI" do |ui|
    ui.dependency "ReactiveRedux/Main"
    ui.source_files = "ReactiveRedux/UI/*"
  end

  s.subspec "Middleware" do |mw|
    mw.dependency "ReactiveRedux/Main"
    mw.source_files = "ReactiveRedux/Middleware/*"
  end
end
