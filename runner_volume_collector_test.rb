require 'minitest/autorun'
require_relative 'assert_exec'
require_relative 'runner_volume_collector'

class RunnerVolumeCollectorTest < MiniTest::Test

  def test_newly_created_volume_has_id_as_set
    @kata_id = 'D1B34B6288'
    volume.create
    begin
      assert_equal @kata_id, volume.id
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_collector_sees_newly_created_volume_doesnt_see_removed_volume
    @kata_id = 'D6C3E9738C'
    refute visible?
    volume.create
    assert visible?
    volume.remove
    refute visible?
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_is_N_hours_old_from_N_hours_in_the_future
    @kata_id = '394277E714'
    volume.create
    begin
      assert visible?
      assert_equal 0, volume.hours_unused(0)
      assert_equal 7, volume.hours_unused(7)
      assert_equal 9, volume.hours_unused(9)
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_non_empty_volume_is_N_hours_old_from_N_hours_in_the_future
    @kata_id = '1E28CDB8FC'
    volume.create
    begin
      volume.start_avatar
      assert visible?
      assert_equal 0, volume.hours_unused(0)
      assert_equal 7, volume.hours_unused(7)
      assert_equal 9, volume.hours_unused(9)
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_less_than_24_hours_old_is_not_collected
    @kata_id = '0BBE594321'
    volume.create
    begin
      collect(23)
      refute collected?
    ensure
      volume.remove
    end
  end

  def test_non_empty_volume_less_than_24_hours_old_is_not_collected
    @kata_id = '4D1B7E3418'
    volume.create
    begin
      volume.start_avatar
      collect(23)
      refute collected?
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_exactly_24_hours_old_is_collected
    @kata_id = 'EDA4E9B752'
    volume.create
    collect(24)
    assert collected?
  end

  def test_non_empty_volume_exactly_24_hours_old_is_collected
    @kata_id = '80A507E758'
    volume.create
    volume.start_avatar
    collect(24)
    assert collected?
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_more_than_24_hours_old_is_collected
    @kata_id = '70CABA2638'
    volume.create
    collect(25)
    assert collected?
  end

  def test_non_empty_volume_more_than_24_hours_old_is_collected
    @kata_id = 'E15B928D44'
    volume.create
    volume.start_avatar
    collect(25)
    assert collected?
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_listing_volumes_shows_their_age
    @kata_id = '571A086F98'
    volume.create
    volume.start_avatar
    list(2)
    assert listed?(2)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_an_exited_kata_container_is_collected
    @kata_id = '3801A8B477'
    name = 'cyber_dojo_kata_container_runner_' + @kata_id
    args = [
      '--detach',
      "--name=#{name}",
      '--net=none',
      '--user=root'
    ].join(space = ' ')
    image_name = 'cyberdojo/collector'
    cmd = "docker run #{args} #{image_name} sh -c 'sleep 1s'"
    assert_exec(cmd)
    sleep 2
    cmd = "docker ps --all --filter name=#{name} --filter status=exited"
    stdout,_ = assert_exec(cmd)
    assert stdout.include?(name), stdout
    collect(0)
    cmd = "docker ps --all --filter name=#{name} --filter status=exited"
    stdout,_ = assert_exec(cmd)
    refute stdout.include?(name), stdout
  end

  private

  def list(hours_in_future)
    shell_cmd = [
      'ruby',
      '/home/runner_volume_collector.rb',
      'list',
      hours_in_future
    ].join(space)
    @log = assert_docker_exec(shell_cmd)
  end

  def listed?(hours_in_future)
    @log.include?("#{@volume.name} #{hours_in_future}")
  end

  def collect(hours_in_future)
    shell_cmd = [
      '/home/run-as-cron',
      '/etc/periodic/hourly/collect_runner_volumes',
      hours_in_future
    ].join(space)
    @log = assert_docker_exec(shell_cmd)
  end

  def collected?
    # not @log == @volume.name as the
    # collection could have genuinely
    # collected other unused volumes.
    !visible? && @log.include?(@volume.name)
  end

  def visible?
    volumes_ids.include? @kata_id
  end

  def volumes_ids
    collector.volumes.map(&:id)
  end

  def collector
    @collector ||= RunnerVolumeCollector.new(volume_pattern)
  end

  def volume
    @volume ||= collector.volume(@kata_id)
  end

  def volume_pattern
    'cyber_dojo_kata_volume_runner'
  end

  def assert_docker_exec(shell_cmd)
    cmd = [
      'docker run',
        '--rm',
        '--volume /var/run/docker.sock:/var/run/docker.sock',
        'cyberdojo/collector',
        "sh -c '#{shell_cmd}'"
    ].join(space)
    assert_exec cmd
  end

  def space
    ' '
  end

  include AssertExec

end
