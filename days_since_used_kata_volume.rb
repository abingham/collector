#!/usr/bin/env ruby

require 'date'

# - - - - - - - - - - - - - - - - - - - - -

def days_since_used_kata_volume(name)
  # Finds the age of the most recently modified file
  # in the DockerKataVolumeRinner's volume named ${name}
  # %Y == seconds since epoch
  sandboxes = "/sandboxes"
  # Note: There could be no files yet under /sandboxes
  stat_sse_dir = "stat -c %Y #{sandboxes}"
  # files under /sandboxes
  stat_sse_files = [
    "find #{sandboxes} -type f -print0",  # print filenames, nul terminated
    '|',
    'xargs',
      ' -r',  # don't run command if input is empty
      ' -0',  # input is separated by nul characters
      ' stat -c %Y'
  ].join

  stat_sse = [
    'docker run',
          '--rm',
          "--volume #{name}:#{sandboxes}:ro",
          'cyberdojo/collector',
          "sh -c '(#{stat_sse_dir};#{stat_sse_files}) | sort -rn | head -1'"
  ].join(space = ' ')

  sse = `#{stat_sse}`  # eg 1484774952
  most_recent = Time.at(sse.to_i).to_datetime # eg 2017-01-18T21:29:12+00:00
  (DateTime.now - most_recent).to_i # eg 1 (day)
end

if ARGV.length == 1
  name = ARGV[0]
  puts days_since_used_kata_volume(name)
end
