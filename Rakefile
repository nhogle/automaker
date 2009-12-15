require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "automaker"
    gem.summary = "Not autotest, not autospec, but automake(r)"
    gem.description = "Will monitor a directory using fsevents api and call make when something changes. Only works on Mac OS X."
    gem.email = "ronaldpaulusevers@gmail.com"
    gem.homepage = "http://github.com/ronaldevers/automaker"
    gem.authors = ["Ronald Evers"]
    gem.add_dependency "fsevents", ">= 0.1.1"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

