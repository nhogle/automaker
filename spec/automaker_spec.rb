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
        `echo "asdf" >> file`
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
        `echo "asdf" >> schleevens/file`
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
    Automaker.run args_string.split
  end
  yield
  thread.join
end
