Pod::Spec.new do |s|
s.name     = 'Unicorn'
s.version  = '1.0.2'
s.license  = 'MIT'
s.summary  = 'Unique model'
s.homepage = 'https://github.com/emsihyo/Unicorn'
s.author   = { 'emsihyo' => 'emsihyo@gmail.com' }
s.source   = { :git => 'https://github.com/emsihyo/Unicorn.git',:tag => "#{s.version}" }
s.description = 'Unique model,used optionally in memory and in database(sqlite),support json mapping.'
s.requires_arc   = true
s.platform     = :ios
s.ios.deployment_target = '8.0'
s.source_files = 'Unicorn/*.{h,m}'
s.libraries = 'sqlite3'
 s.xcconfig = {
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
    }
end
