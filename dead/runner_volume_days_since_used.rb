#!/usr/bin/env ruby

require 'date'
require_relative 'assert_exec'

include AssertExec

def space; ' '; end
def sandboxes; '/sandboxes'; end

def runner_volume_days_since_used(name)
  # Finds the age of the most recently modified file
  # in the cyberdojo/runner's volume named ${name}
  # %Y == Time of last modification as seconds since Epoch
  # Note: /sandboxes is empty till an avatar starts
  stat_sse_dir = "stat -c %Y #{sandboxes}"
  # files under /sandboxes
  stat_sse_files = [
    "find #{sandboxes} -type f -print0",  # print filenames, nul terminated
      '|',
        'xargs',
          '-r',  # don't run command if input is empty
          '-0',  # input is separated by nuls
          'stat -c %Y'
  ].join(space)

  stat_sse = [
    'docker run',
      '--rm',
      "--volume #{name}:#{sandboxes}:ro",
      'cyberdojo/collector',
      "sh -c '(#{stat_sse_dir};#{stat_sse_files}) | sort -rn | head -1'"
  ].join(space)

  sse = assert_exec(stat_sse) # eg 1484774952
  most_recent = Time.at(sse.to_i).to_datetime # eg 2017-01-18T21:29:12+00:00
  (DateTime.now - most_recent).to_i # eg 1 (day)
end

name = ARGV[-1]
puts runner_volume_days_since_used(name)
