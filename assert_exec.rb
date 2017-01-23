
require 'open3'

module AssertExec # mix-in

  def assert_exec(cmd)
    stdout,stderr,status = Open3.capture3(cmd)
    if status != 0
      raise ArgumentError.new("#{stdout}:#{stderr}:#{status}:#{cmd}")
    end
    stdout
  end

end
