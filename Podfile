# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def allPods
  pod 'RxSwift'
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

    pod 'RxTest'
    pod 'SafeNest/Main', git: 'https://github.com/protoman92/SafeNest.git'
  end
  
  target 'HMReactiveRedux-Demo' do
    inherit! :search_paths
    # Pods for demo
    allPods
    pod 'RxCocoa'
    pod 'SafeNest/Main', git: 'https://github.com/protoman92/SafeNest.git'
  end
end
