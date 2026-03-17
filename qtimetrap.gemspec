# frozen_string_literal: true

require_relative 'lib/qtimetrap/version'

Gem::Specification.new do |spec|
  spec.name = 'qtimetrap'
  spec.version = QTimetrap::VERSION
  spec.authors = ['Maksim Veynberg']
  spec.email = ['mv@cj264.ru']

  spec.summary = 'Desktop Timetrap UI on Qt'
  spec.description = 'MVVM Ruby desktop app for Timetrap built with Qt and Zeitwerk.'
  spec.homepage = 'https://github.com/CyJimmy264/qtimetrap'
  spec.license = 'BSD-2-Clause'
  spec.required_ruby_version = '>= 3.2'

  spec.files = Dir[
    'app/**/*',
    'bin/*',
    'config/**/*',
    'lib/**/*.rb',
    'README.md',
    'CHANGELOG.md',
    'LICENSE',
    'Rakefile'
  ]

  spec.bindir = 'bin'
  spec.executables = ['qtimetrap']
  spec.require_paths = ['lib']

  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'qt', '~> 0.1', '>= 0.1.7'
  spec.add_dependency 'zeitwerk', '~> 2.6'
end
