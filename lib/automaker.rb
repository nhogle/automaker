require 'rubygems'
require 'rb-inotify'

class Automaker
  def run(args)
    @path_to_watch = args.shift || "."
    @path_to_build = args.shift || "./build"
    @filters = args
    run_stream
    0
  end

  def print_usage
   $stderr.puts "Usage: automaker </path/to/watch> </path/to/build> [filter [filter [ etc.. ]]]
You must specify the path to watch. Make is only triggered if a file whose name
one of the filters is changed. (Otherwise you will likely enter an infinite loop.)"
  end

  def run_stream
    notifier = INotify::Notifier.new
    notifier.watch @path_to_watch, :modify do |event|
      make if should_make [event.name]
    end
    notifier.run
  end
  
  def should_make(modified_files)
    modified_files.any? do |filename|
      @filters.empty? or @filters.any? { |filter| filename.include?(filter) }
    end
  end
  
  def make
    system("cd #{@path_to_build} && make")
  end
end
