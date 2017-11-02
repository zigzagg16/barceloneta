Pod::Spec.new do |s|
  s.name         = "barceloneta"
  s.version      = "1.0.2"
  s.summary      = "The right way to increment/decrement values with a simple gesture on iOS."
  s.description  = <<-DESC
                   Barceloneta is the right way to increment/decrement values with a simple gesture on iOS
                   DESC
  s.homepage     = "https://github.com/arn00s/barceloneta"
  s.screenshots  = "https://raw.githubusercontent.com/arn00s/barceloneta/master/img/barceloneta.gif"
  s.license      = "MIT"
  s.author             = { "Arnaud Schloune" => "arnaud.schloune@gmail.com" }
  s.social_media_url   = "https://twitter.com/mmommommomo"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/arn00s/barceloneta.git", :tag => "1.0.2" }
  s.source_files  = "Classes", "Barceloneta/Library/Barceloneta.swift"
  s.requires_arc = true
end
