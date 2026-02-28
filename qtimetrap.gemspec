# frozen_string_literal: true

require_relative 'lib/qtimetrap/version'

Gem::Specification.new do |spec|
  spec.name = 'qtimetrap'
  spec.version = QTimetrap::VERSION
  spec.authors = ['mveynberg']
  spec.email = ['dev@example.com']

  spec.summary = 'Desktop Timetrap UI on Qt'
  spec.description = 'MVVM Ruby desktop app for Timetrap built with Qt and Zeitwerk.'
  spec.homepage = 'https://example.com/qtimetrap'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.glob('{app,bin,config,lib}/**/*', File::FNM_DOTMATCH).reject do |path|
    File.directory?(path)
  end
  spec.bindir = 'bin'
  spec.executables = ['qtimetrap']
  spec.require_paths = ['lib']

  spec.add_dependency 'qt'
  spec.add_dependency 'zeitwerk', '~> 2.6'
  spec.add_development_dependency 'bundler', '>= 2.4'
  spec.add_development_dependency 'rake', '>= 13.0'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'simplecov', '~> 0.22'
end
