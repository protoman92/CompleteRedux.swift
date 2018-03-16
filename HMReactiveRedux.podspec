Pod::Spec.new do |s|
    s.platform = :ios
    s.ios.deployment_target = '9.0'
    s.name = "HMReactiveRedux"
    s.summary = "Rx-enabled Redux implementation for iOS clients."
    s.requires_arc = true
    s.version = "1.0.0"
    s.license = { :type => "Apache-2.0", :file => "LICENSE" }
    s.author = { "Hai Pham" => "viethai.pham@Hai Pham.com" }
    s.homepage = "https://github.com/protoman92/HMReactiveRedux-iOS.git"
    s.source = { :git => "https://github.com/protoman92/HMReactiveRedux-Swift.git", :tag => "#{s.version}"}
    s.dependency 'SwiftUtilities/Main+Rx'

    s.subspec 'Main' do |main|
      main.source_files = "HMReactiveRedux/**/*.{swift}"
    end
end
