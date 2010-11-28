require "rubygems"
require "automaker"
require "fileutils"
require "ruby-debug"

PWD = `pwd`.chomp
PROJECT_PATH = "#{PWD}/tmp/project"
BUILD_PATH = "#{PROJECT_PATH}/build"
MAKEFILE = <<-MAKEFILE
all:
	touch ../deliverable
MAKEFILE

class AutomakerTest < Automaker
  private
    def notifier
      @notifier ||= begin
        INotify::Notifier.new.tap do |notifier|
          def notifier.run
            if IO.select([self.to_io], [], [], 2)
              self.process
            end
          end
        end
      end
    end
end

describe Automaker do
  before do
    FileUtils.mkdir_p BUILD_PATH
    File.open "#{BUILD_PATH}/Makefile", "w" do |f|
      f.write MAKEFILE
    end
  end

  it "runs make when I change a file" do
    Dir.chdir PROJECT_PATH do
      automaker do
        `echo "asdf" >> #{PROJECT_PATH}/file`
      end
      File.exists?("deliverable").should be_true
    end
  end

  it "takes arguments for watch path and build path" do
    automaker "#{PROJECT_PATH}/ #{BUILD_PATH}" do
      `echo "asdf" >> #{PROJECT_PATH}/file`
    end
    File.exists?("#{PROJECT_PATH}/deliverable").should be_true
  end

  it "takes options from an .automaker file" do
    Dir.chdir PROJECT_PATH do
      FileUtils.mv "build", "ballzac"
      FileUtils.mkdir "schleevens"
      File.open ".automaker", "w" do |f|
        f.write <<-AUTOMAKER.gsub(/^ {10}/, '')
          :path_to_watch: schleevens
          :path_to_build: ballzac
        AUTOMAKER
      end

      automaker do
        `echo "asdf" >> schleevens/file 2>&1`
      end
      File.exists?("deliverable").should be_true
    end
  end

  it "takes a set of filters as a whitelist" do
    Dir.chdir PROJECT_PATH do
      automaker ". ./build .cpp" do
        `echo "asdf" >> file.h`
      end
      File.exists?("deliverable").should_not be_true

      automaker ". ./build .cpp" do
        `echo "asdf" >> file.cpp`
      end
      File.exists?("deliverable").should be_true
    end
  end

  after do
    FileUtils.rm_rf PROJECT_PATH
  end
end

def automaker(args_string = "")
  thread = Thread.new do
    ENV["test"] = "true"
    AutomakerTest.run args_string.split
  end

  Thread.new do
    while true
      yield
      sleep 0.1
    end
  end

  thread.join
end
