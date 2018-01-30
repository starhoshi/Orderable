Pod::Spec.new do |s|
  s.name               = "Orderable"
  s.version            = "0.2.0"
  s.summary            = "Orderable"
  s.description        = "Orderable can be paid using firebase and stripe."
  s.homepage           = "https://github.com/starhoshi/Orderable"
  s.license            = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "star__hoshi" => "kensuke1751@gmail.com" }
  s.social_media_url   = "https://twitter.com/star__hoshi"
  s.platform           = :ios, "10.0"
  s.source             = { :git => "https://github.com/starhoshi/Orderable.git", :tag => "#{s.version}" }
  s.source_files       = "Orderable/**/*.swift"
  s.requires_arc       = true
  s.static_framework   = true

  s.dependency "Pring"
end

