require 'rake'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :spec

desc 'Test the magic_enum plugin.'
RSpec::Core::RakeTask.new(:spec)

desc 'Generate documentation for the magic_enum plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MagicEnum'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
