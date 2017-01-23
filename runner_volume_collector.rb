require_relative 'assert_exec'
require_relative 'runner_volume'

# Collects volumes created by cyberdojo/runner docker container.

class RunnerVolumeCollector

  def initialize(volume_pattern)
    @volume_pattern = volume_pattern # eg cyber_dojo_kata_volume_runner_BB6BDA27C1
  end

  def collect(days_into_future = 0)
    volumes.each do |volume|
      if volume.days_unused(days_into_future) >= 7
        # TODO: log the removal
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
# The filter patterns must _NOT_ match the
# name of the katas-data-volume which is
# cyber-dojo-katas-DATA-CONTAINER.

if ARGV[-1] == 'collect'
  RunnerVolumeCollector.new.collect

  [ 'cyber_dojo_kata_volume_runner',
    'cyber_dojo_avatar_volume_runner_avatar',
    'cyber_dojo_avatar_volume_runner_kata'
  ].each do |pattern|
    #RunnerCollector.new(pattern).collect
  end

end
