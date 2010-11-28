require "rubygems"
require "automaker"
require "fileutils"

PROJECT_PATH = "tmp/project"
BUILD_PATH = "#{PROJECT_PATH}/build"
MAKEFILE = """
all:
	touch ../deliverable
"""

describe Automaker do
  before do
    FileUtils.mkdir_p BUILD_PATH
    File.open "#{BUILD_PATH}/Makefile", "w" do |f|
      f.write MAKEFILE
    end
  end

  it "runs make when I change a file" do
    automaker "#{PROJECT_PATH}/ #{BUILD_PATH} file" do
      `echo "asdf" >> #{PROJECT_PATH}/file`
    end
    File.exists?("#{PROJECT_PATH}/deliverable").should be_true
  end
end

def automaker(args)
  pid = fork do
    puts `./bin/automaker #{args} &2>1`
  end
  sleep 1
  yield
  sleep 1
  Process.kill 9, pid
  Process.waitpid pid
end

at_exit do
  FileUtils.rm_rf PROJECT_PATH
end
