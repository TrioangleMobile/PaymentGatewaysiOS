# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'PaymentHelper' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PaymentHelper
    pod 'Stripe'
    pod 'Braintree'
    pod 'BraintreeDropIn'
    
  target 'PaymentHelperTests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          blacklistedConfigurations = Array["Debug"]
          
          if target.name == "Braintree" || target.name == "BraintreeDropIn"
            if blacklistedConfigurations.include?(config.name)
              config.build_settings["EXCLUDED_ARCHS"] = "arm64"
            end
          end
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
          config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
          config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
       config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
