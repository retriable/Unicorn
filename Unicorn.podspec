Pod::Spec.new do |spec|
    spec.name     = 'Unicorn'
    spec.version  = '3.1.7'
    spec.license  = 'MIT'
    spec.summary  = 'Json model,single model,db model'
    spec.homepage = 'https://github.com/retriable/Unicorn'
    spec.author   = { 'retriable' => 'retriable@retriable.com' }
    spec.source   = { :git => 'https://github.com/retriable/Unicorn.git',:tag => "#{spec.version}" }
    spec.description = 'Json model,single model,db model.'
    spec.requires_arc = true
    spec.source_files = 'Unicorn/*.{h,m}'
    spec.framework = 'CoreGraphics'
    spec.ios.framework = 'UIKit'
    spec.tvos.framework = 'UIKit'
    spec.watchos.framework = 'UIKit'
    spec.ios.deployment_target = '8.0'
    spec.watchos.deployment_target = '2.0'
    spec.tvos.deployment_target = '9.0'
    spec.osx.deployment_target = '10.10'
end
