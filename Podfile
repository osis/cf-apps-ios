platform :ios, '9.0'
use_frameworks!

pod 'CFoundry', :git => 'https://github.com/osis/cf-swift-sdk.git'

target 'CF Apps' do
    pod 'ActionSheetPicker-3.0', '~> 2.2.0'
end

target 'CF Apps UITests' do
  pod 'Swifter', '~> 1.4.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            case target.name
            when "ProtocolBuffers-Swift"
                config.build_settings['SWIFT_VERSION'] = '3.3'
            end
        end
    end
end
