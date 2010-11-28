require 'rubygems'
require 'rb-inotify'

class Automaker
  def run
    if !check_arguments
      print_usage
      1
    else
      @path_to_watch = ARGV.shift
      @path_to_build = ARGV.shift
      @filters = ARGV
      run_stream
      0
    end
  end

  def check_arguments
    ARGV.size > 1
  end
  
  def print_usage
   $stderr.puts "Usage: automaker </path/to/watch> </path/to/build> <filter> [filter [filter [ etc.. ]]]
You must specify the path to watch. Make is only triggered if a file whose name
one of the filters is changed. (Otherwise you will likely enter an infinite loop.)"
  end

  def run_stream
    notifier = INotify::Notifier.new
    notifier.watch @path_to_watch, :modify do |event|
      puts "omg"
      make if should_make [event.name]
    end
    notifier.run
  end
  
  def should_make(modified_files)
    modified_files.each { |filename|
      @filters.each { |filter|
        return true if filename.include?(filter)
      }
    }
    false
  end
  
  def make
    system("cd #{@path_to_build} && make")
  end
end
