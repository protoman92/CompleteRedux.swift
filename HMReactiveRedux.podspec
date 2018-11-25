Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.name = "HMReactiveRedux"
  s.summary = "Rx-enabled Redux implementation for iOS clients."
  s.requires_arc = true
  s.version = "1.0.1"
  s.license = { :type => "Apache-2.0", :file => "LICENSE" }
  s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
  s.homepage = "https://github.com/protoman92/HMReactiveRedux-Swift.git"
  s.source = { :git => "https://github.com/protoman92/HMReactiveRedux-Swift.git", :tag => "#{s.version}"}
  s.dependency 'SwiftFP/Main'

  s.subspec 'Main' do |m|
    m.source_files = "HMReactiveRedux/*.{*}", "HMReactiveRedux/Preset/*.{*}"
  end

  s.subspec 'Rx' do |mrx|
    mrx.dependency 'RxSwift', '~> 4.0'
    mrx.source_files = "HMReactiveRedux/RxStore/*.{swift}"
  end
end
