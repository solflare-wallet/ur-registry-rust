#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ur_registry_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ur_registry_flutter'
  s.version          = '0.0.6'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.public_header_files = 'Classes**/*.h'
  s.source_files = 'Classes/**/*'
  # The original plugin bundled a `cargo lipo` static archive, which gives us
  # an arm64 device slice but not an arm64-simulator slice. Apple Silicon
  # simulators require the latter, so use the upstream XCFramework packaging
  # path that contains both iOS and iOS Simulator binaries.
  s.vendored_frameworks = 'URRegistryFFI.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  s.pod_target_xcconfig = {
    # Keep the pod as a module for the generated Swift/ObjC compatibility header.
    'DEFINES_MODULE' => 'YES'
  }
  s.swift_version = '5.0'
end
