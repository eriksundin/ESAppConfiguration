Pod::Spec.new do |s|
  s.name         = "ESAppConfiguration"
  s.version      = "1.0.0"
  s.license  = 'MIT'  
  s.summary      = "A reusable class for handling configuration (static / mutable) in an application."
  s.homepage     = "https://github.com/eriksundin/ESAppConfiguration"

  s.author       = { "Erik Sundin" => "erik@eriksundin.se" }
  s.source       = { :git => "https://github.com/eriksundin/ESAppConfiguration.git", :tag => "1.0.0" }
  
  s.platform     = :ios
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.requires_arc = true
end
