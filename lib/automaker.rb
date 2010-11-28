require 'rubygems'
require 'rb-inotify'
require 'yaml'

class Automaker
  def self.run(args)
    options = { :path_to_watch => args.shift,
      :path_to_build => args.shift,
      :filters => args }
    options.delete_if { |key, value| value.nil? }
    new options
  end

  def initialize(options)
    @options = default_options.merge(options_from_file).merge(options)
    run_stream
    0
  end

  def print_usage
    $stderr.puts "Usage: automaker [/path/to/watch] [/path/to/build] [filter [filter [ etc.. ]]]
You must specify the path to watch. Make is only triggered if a file whose name
one of the filters is changed. (Otherwise you will likely enter an infinite loop.)"
  end

  def run_stream
    notifier.watch path_to_watch, :modify do |event|
      make if should_make [event.name]
    end
    notifier.run
  end
  
  def should_make(modified_files)
    modified_files.any? do |filename|
      filters.empty? or filters.any? { |filter| filename.include?(filter) }
    end
  end
  
  def make
    command = "cd #{path_to_build} && make"
    ENV["test"] ? `#{command}` : system(command)
  end

  private
    def notifier
      @notifier ||= INotify::Notifier.new
    end

    def default_options
      { :path_to_watch => ".",
        :path_to_build => "./build" }
    end

    def options_from_file
      File.exist?(".automaker") ? YAML.load_file(".automaker") : {}
    end

    def path_to_watch
      @options[:path_to_watch]
    end

    def path_to_build
      @options[:path_to_build]
    end

    def filters
      @options[:filters]
    end
end
