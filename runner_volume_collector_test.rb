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

  def test_empty_volume_is_N_days_old_from_N_days_in_the_future
    @kata_id = '394277E714'
    volume.create
    begin
      assert visible?
      assert_equal 0, volume.days_unused(0)
      assert_equal 7, volume.days_unused(7)
      assert_equal 9, volume.days_unused(9)
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_non_empty_volume_is_N_days_old_from_N_days_in_the_future
    @kata_id = '1E28CDB8FC'
    volume.create
    begin
      volume.start_avatar
      assert visible?
      assert_equal 0, volume.days_unused(0)
      assert_equal 7, volume.days_unused(7)
      assert_equal 9, volume.days_unused(9)
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_less_than_7_days_old_is_not_collected
    @kata_id = '0BBE594321'
    volume.create
    begin
      collector.collect(6)
      refute collected?
    ensure
      volume.remove
    end
  end

  def test_non_empty_volume_less_than_7_days_old_is_not_collected
    @kata_id = '4D1B7E3418'
    volume.create
    begin
      volume.start_avatar
      collector.collect(6)
      refute collected?
    ensure
      volume.remove
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_exactly_7_days_is_collected
    @kata_id = 'EDA4E9B752'
    volume.create
    collector.collect(7)
    assert collected?
  end

  def test_non_empty_volume_exactly_7_days_is_collected
    @kata_id = '80A507E758'
    volume.create
    volume.start_avatar
    collector.collect(7)
    assert collected?
  end

  # - - - - - - - - - - - - - - - - - - - -

  def test_empty_volume_more_than_7_days_old_is_collected
    @kata_id = '70CABA2638'
    volume.create
    collector.collect(8)
    assert collected?
  end

  def test_non_empty_volume_more_than_7_days_old_is_collected
    @kata_id = 'E15B928D44'
    volume.create
    volume.start_avatar
    collector.collect(8)
    assert collected?
  end

  private

  include AssertExec

  def collected?
    !visible?
  end

  def visible?
    volumes_ids.include? @kata_id
  end

  def volumes_ids
    collector.volumes.map(&:id)
  end

  def collector
    volume_pattern = 'cyber_dojo_kata_volume_runner'
    @collector ||= RunnerVolumeCollector.new(volume_pattern)
  end

  def volume
    @volume ||= collector.volume(@kata_id)
  end

end
