require 'minitest/autorun'

class ShaTest < MiniTest::Test

  def test_sha_of_git_commit_for_image_lives_in_home
    cmd = <<~BASH
      docker run --rm -it cyberdojo/collector \
      sh -c 'cat /home/sha.txt'
    BASH
    sha = `#{cmd}`.strip
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

end
