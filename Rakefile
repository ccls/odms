require(File.join(File.dirname(__FILE__), 'config', 'boot'))

#	Newer versions are incompatible with rdoc_rails gem/plugin
#gem 'rdoc', '~> 2'

#	Use the updated rdoc gem rather than version
#	included with ruby.
require 'rdoc'
require 'rdoc/rdoc'

require 'rake'
require 'rake/testtask'
#require 'rake/rdoctask'
require 'rdoc/task'

require 'tasks/rails'

#	Must come after rails as overrides doc:app
#if g = Gem.source_index.find_name('jakewendt-rdoc_rails').last
#	gem 'jakewendt-rdoc_rails'
#	require 'rdoc_rails'
#	load "#{g.full_gem_path}/lib/tasks/rdoc_rails.rake"
#end
