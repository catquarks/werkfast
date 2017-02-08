# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "Werkfast"
  spec.version       = '1.0'
  spec.authors       = ["Tamara Jaton"]
  spec.email         = ["tamara.jaton@gmail.com"]
  spec.summary       = %q{'A CLI tool to help me werk faster.'}
  spec.description   = %q{'Downloads, scrapes, and formats emails from Gmail into ODT files using Nokogiri.'}
  spec.homepage      = "http://tamarajaton.xyz/"
  spec.license       = "MIT"

  spec.files         = ['lib/*.rb']
  spec.executables   = ['bin/*.rb']
  spec.test_files    = ['spec/*_spec.rb']
  spec.require_paths = ["lib"]
end
