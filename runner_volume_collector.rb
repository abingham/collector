require_relative 'assert_exec'
require_relative 'runner_volume'

# Collects docker container and volumes
# created by cyberdojo/runners.

class RunnerVolumeCollector

  def initialize(volume_pattern)
    # eg cyber_dojo_kata_volume_runner_BB6BDA27C1
    @volume_pattern = volume_pattern
  end

  def list(options = {})
    hours_in_future  = options[:hours_in_future ] || 0
    max_hours_unused = options[:max_hours_unused] || 24
    volumes.each do |volume|
      hours_unused = volume.hours_unused(hours_in_future)
      puts "#{volume.name} #{hours_unused} hour(s) unused"
    end
  end

  def collect(options = {})
    hours_in_future  = options[:hours_in_future ] || 0
    max_hours_unused = options[:max_hours_unused] || 24
    volumes.each do |volume|
      hours_unused = volume.hours_unused(hours_in_future)
      if hours_unused >= max_hours_unused
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

def volume_patterns
  [ 'cyber_dojo_kata_container_runner',
    'cyber_dojo_kata_volume_runner',
    'cyber_dojo_avatar_volume_runner_avatar',
    'cyber_dojo_avatar_volume_runner_kata'
  ]
end

# - - - - - - - - - - - - - - - - -

default_hours_in_future  = '0'
default_max_hours_unused = '24'

hours_in_future  = (ARGV[1] || default_hours_in_future ).to_i
max_hours_unused = (ARGV[2] || default_max_hours_unused).to_i

options = {
   hours_in_future:hours_in_future,
  max_hours_unused:max_hours_unused
}

# - - - - - - - - - - - - - - - - -

if ARGV[0] == 'list'
  volume_patterns.each do |pattern|
    RunnerVolumeCollector.new(pattern).list(options)
  end
end

if ARGV[0] == 'collect'
  # first collect all exited runner containers
  pids = `docker ps --all --quiet --filter 'name=cyber_dojo_kata_container_runner_' --filter 'status=exited'`
  if pids != ''
    `docker rm #{pids}`
  end
  # then collect all runner volumes not used in last 7 days
  volume_patterns.each do |pattern|
    RunnerVolumeCollector.new(pattern).collect(options)
  end
end
