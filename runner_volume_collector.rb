require_relative 'assert_exec'
require_relative 'runner_volume'

# Collects volumes created by
# cyberdojo/runner docker container.

class RunnerVolumeCollector

  def initialize(volume_pattern)
    # eg cyber_dojo_kata_volume_runner_BB6BDA27C1
    @volume_pattern = volume_pattern
  end

  def collect(options = {})
    days_in_future  = options[:days_in_future ] || 0
    max_days_unused = options[:max_days_unused] || 7
    volumes.each do |volume|
      if volume.days_unused(days_in_future) >= max_days_unused
        puts volume.name
        volume.remove
      end
    end
  end

  def volume(kata_id)
    RunnerVolume.new(volume_pattern + '_' + kata_id)
  end

  def volumes
    shell_cmd = [
      'docker volume ls',
        '--quiet',
        '--filter',
        "'name=#{volume_pattern}'"
    ].join(space = ' ')
    ls = assert_exec(shell_cmd)
    names = ls.split("\n")
    names.map { |name| RunnerVolume.new(name) }
  end

  private

  attr_reader :volume_pattern

  include AssertExec

end

# - - - - - - - - - - - - - - - - -

if ARGV[0] == 'collect'
  # first collect all exited runner containers
  pids = `docker ps --all --quiet --filter 'name=cyber_dojo_kata_container_runner_' --filter 'status=exited'`
  if pids != ''
    `docker rm #{pids}`
  end
  # then collect all runner volumes not used in last 7 days
  default_days_in_future  = '0'
  default_max_days_unused = '7'
  days_in_future  = (ARGV[1] || default_days_in_future ).to_i
  max_days_unused = (ARGV[2] || default_max_days_unused).to_i
  options = {
     days_in_future:days_in_future,
    max_days_unused:max_days_unused
  }
  # collect volumes from all runners
  [ 'cyber_dojo_kata_container_runner',
    'cyber_dojo_kata_volume_runner',
    'cyber_dojo_avatar_volume_runner_avatar',
    'cyber_dojo_avatar_volume_runner_kata'
  ].each do |pattern|
    RunnerVolumeCollector.new(pattern).collect(options)
  end

end
