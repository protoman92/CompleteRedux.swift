Pod::Spec.new do |s|
    s.platform = :ios
    s.ios.deployment_target = '8.0'
    s.name = "HMReactiveRedux"
    s.summary = "Rx-enabled Redux implementation for iOS clients."
    s.requires_arc = true
    s.version = "1.0.0"
    s.license = { :type => "Apache-2.0", :file => "LICENSE" }
    s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
    s.homepage = "https://github.com/protoman92/HMReactiveRedux-Swift.git"
    s.source = { :git => "https://github.com/protoman92/HMReactiveRedux-Swift.git", :tag => "#{s.version}"}

    s.subspec 'Main+Rx' do |mrx|
			mrx.dependency 'SwiftUtilities/Main+Rx'
      mrx.source_files = "HMReactiveRedux/**/*.{swift}"
			mrx.exclude_files = "HMReactiveRedux/DispatchStore/**/*.{swift}"
    end

		s.subspec 'Main+Dispatch' do |md|
			md.dependency 'SwiftUtilities/Main'
			md.source_files = "HMReactiveRedux/**/*.{swift}"
			md.exclude_files = "HMReactiveRedux/RxStore/**/*.{swift}"
		end
end
