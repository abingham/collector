require_relative 'assert_exec'

# Represents a volume created from a
# cyberdojo/runner docker container.

class RunnerVolume

  def initialize(name)
    @name = name
  end

  attr_reader :name

  def id
    name.split('_')[-1] # eg BB6BDA27C1
  end

  def create
    assert_exec "docker volume create --name #{name}"
  end

  def start_avatar
    lion_dir = "#{sandboxes}/lion"
    cmd = "mkdir #{lion_dir} && touch #{lion_dir}/manifest.json"
    assert_docker_exec cmd
  end

  def remove
    assert_exec "docker volume rm #{name}"
  end

  def hours_unused(hours_in_future = 0)
    # The number of hours since the volume has been
    # used as if we were asking hours_in_future.
    # stat: %Y == time of last modification as seconds since Epoch
    stat_sse_dir = "stat -c %Y #{sandboxes}"
    stat_sse_files = [
      "find #{sandboxes} -type f -print0", # print filenames, nul terminated
      '|',
        'xargs',
          '-r',        # don't run command if input is empty
          '-0',        # input is separated by nuls
          'stat -c %Y'
    ].join(space)
    stat_sse = "(#{stat_sse_dir};#{stat_sse_files})"
    sse = assert_docker_exec(stat_sse)         # eg 1484774952 ... 1484774964
    max_sse = sse.split.map{ |s| s.to_i }.max  # eg 1484774964
    most_recent = Time.at(max_sse)             # eg 2017-01-18T21:29:24+00:00
    secs_in_future = hours_in_future * 60 * 60 # eg 986400
    future = Time.now + secs_in_future         # eg 2017-01-30T08:28:58+00:00
    (future.to_i - most_recent.to_i) / 60 / 60 # eg 274 hours (11 days)
  end

  private

  include AssertExec

  def assert_docker_exec(shell_cmd)
    cmd = [
      'docker run',
        '--rm',
        "--volume #{name}:#{sandboxes}:rw",
        'cyberdojo/collector',
        "sh -c '#{shell_cmd}'"
    ].join(space)
    assert_exec cmd
  end

  def sandboxes
    '/sandboxes'
  end

  def space
    ' '
  end

end

