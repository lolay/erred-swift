Pod::Spec.new do |s|
  s.name = 'LolayErred'
  s.version = '2.0'
  s.license = {:type => 'Apache License, Version 2.0', :file => 'LICENSE'}
  s.summary = 'Lolay error handling manager'
  s.homepage = 'https://github.com/lolay/erred-swift'
  s.authors = { 'Lolay, Inc.' => 'info@lolay.com' }
  s.source = { :git => 'https://github.com/lolay/erred-swift.git', :tag => s.version }
  s.swift_version = "5.0"
  s.module_name = "LolayErred"
  s.ios.deployment_target = '16.0'
  s.source_files = 'LolayErred/*.swift'
end
