Gem::Specification.new do |s|
  s.name        = 'parrot_tn'
  s.version     = '0.1.0'
  s.date        = '2012-07-10'
  s.summary     = "Parrot translator"
  s.description = "Tool to translate messages"
  s.authors     = ["Philippe Thomann"]
  s.email       = 'thomann.philipps@gmail.com'

  s.files         = Dir['lib/**/*']
  s.test_files    = Dir['spec/**/*.rb']
  s.executables   = %w{parrot}

  s.homepage    =
    'http://rubygems.org/gems/parrot_tn'
end
