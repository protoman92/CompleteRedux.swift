# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'CompleteRedux' do
  use_frameworks!

  # Pods for CompleteRedux
  pod 'RxSwift', '~> 4.0'
  pod 'RxBlocking', '~> 4.0'
  pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
  
  target 'CompleteReduxTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'
    pod 'SafeNest/Main', git: 'https://github.com/protoman92/SafeNest.git'
  end
  
  target 'CompleteRedux-Demo' do
    inherit! :search_paths
    # Pods for demo
    pod 'RxBlocking', '~> 4.0'
    pod 'SafeNest/Main', git: 'https://github.com/protoman92/SafeNest.git'
    pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
  end
  
  target 'CompleteRedux-MusicDemo' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 4.0'
    pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
  end
end
