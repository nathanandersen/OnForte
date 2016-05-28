# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
 use_frameworks!

target 'OnForte' do
  pod "SwiftDDP", "~> 0.2.1"
  pod 'Soundcloud'
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
  pod 'Alamofire', '~> 3.0'
  pod 'AlamofireImage', '~> 2.0'
  pod 'BFPaperButton', '~> 2.0'
  pod 'MMDrawerController', '~> 0.5.7'
  pod 'NVActivityIndicatorView', '~> 2.3'
end

target 'OnForteTests' do

end

target 'OnForteUITests' do

end

post_install do |installer|
  plist_buddy = "/usr/libexec/PlistBuddy"

  installer.pods_project.targets.each do |target|
    plist = "Pods/Target Support Files/#{target}/Info.plist"
    version = `#{plist_buddy} -c "Print CFBundleShortVersionString" "#{plist}"`.strip

    stripped_version = /([\d\.]+)/.match(version).captures[0]

    version_parts = stripped_version.split('.').map { |s| s.to_i }

    # ignore properly formatted versions
    unless version_parts.slice(0..2).join('.') == version

      major, minor, patch = version_parts

      major ||= 0
      minor ||= 0
      patch ||= 999

      fixed_version = "#{major}.#{minor}.#{patch}"

      puts "Changing version of #{target} from #{version} to #{fixed_version} to make it pass iTC verification."

      `#{plist_buddy} -c "Set CFBundleShortVersionString #{fixed_version}" "#{plist}"`
    end
  end
end
