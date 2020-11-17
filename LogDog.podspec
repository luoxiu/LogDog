Pod::Spec.new do |s|
    s.name                = 'LogDog'
    s.version             = '0.2.0'
    s.summary             = 'Friendly logging.'
    s.homepage            = 'https://github.com/luoxiu/LogDog'
  
    s.license             = { type: 'MIT', file: 'LICENSE' }
  
    s.author              = { 'luoxiu' => 'luoxiustm@gmail.com' }
  
    s.ios.deployment_target = '10.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '10.0'
    s.watchos.deployment_target = '3.0'
    
    s.swift_version = '5.0'
    
    s.source              = { git: s.homepage + '.git', tag: s.version }
    s.source_files        = 'Sources/LogDog/**/*.swift'

    s.dependency 'Logging', '~> 1.0'
end
  
