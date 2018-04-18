# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def allPods
  pod 'RxSwift', '~> 4.0'
  pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
end

target 'HMReactiveRedux' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  allPods

  # Pods for HMReactiveRedux

  target 'HMReactiveReduxTests' do
    inherit! :search_paths
    # Pods for testing
    allPods

    pod 'SwiftUtilities/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
    pod 'SwiftUtilitiesTests/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
  end
  
  target 'HMReactiveRedux-Demo' do
    inherit! :search_paths
    # Pods for demo
    allPods
    pod 'RxCocoa', '~> 4.0'
    pod 'SwiftUtilities/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
  end
end
