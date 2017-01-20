#!/usr/bin/env ruby

require 'date'

# Collects old docker volumes created by the DockerKataVolumeRunner
# which creates a volume per kata.

# - - - - - - - - - - - - - - - - - - - - -

# The filter patterns must _NOT_ match the
# name of the katas-data-volume which is
# cyber-dojo-katas-DATA-CONTAINER.

def kata_pattern
  'cyber_dojo_kata_volume_runner'
end

# - - - - - - - - - - - - - - - - - - - - -

def volume_names(pattern)
  cmd = "docker volume ls --quiet --filter 'name=#{pattern}'"
  `#{cmd}`.split
end

# - - - - - - - - - - - - - - - - - - - - -

def gather_kata_ids
  kata_ids = []
  volume_names(kata_pattern).each do |volume_name|
    # eg cyber_dojo_kata_volume_runner_AC6B15895D
    parts = volume_name.split('_')
    kata_id = parts[5] # eg AC6B15895D
    kata_ids << kata_id
  end
  kata_ids
end

# - - - - - - - - - - - - - - - - - - - - -

def collect_old_kata_volumes(kata_ids)
  kata_ids.each do |kata_id|
    days_old = last_modified(kata_id)
    puts "DockerKataVolumeRunner: #{kata_id} - #{days_old} days old"
    if days_old >= 7
      kata_collect(kata_id)
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - -

def last_modified(kata_id)
  name = [ kata_pattern, kata_id ].join('_')
  puts ":#{name}:"
  sandboxes = "/sandboxes"
  # find the most recently modified file. %Y == seconds since epoch
  cmd = [ 'docker run',
          '--rm',
          '-it',
          "--volume #{name}:#{sandboxes}:ro",
          'cyberdojo/collector',
          "sh -c 'find #{sandboxes} -type f -print0 | xargs -0 stat -c %Y | sort -rn | head -1'"
  ].join(space = ' ')
  sse = `#{cmd}`  # eg 1484774952
  most_recent = Time.at(sse.to_i).to_datetime # eg 2017-01-18T21:29:12+00:00
  (DateTime.now - most_recent).to_i # eg 1 (day)
end

# - - - - - - - - - - - - - - - - - - - - -

def kata_collect(kata_id)
  name = [ kata_pattern, kata_id ].join('_')
  cmd = "docker volume rm #{name}"
  `#{cmd}`
end

# - - - - - - - - - - - - - - - - - - - - -

kata_ids = gather_kata_ids
collect_old_kata_volumes(kata_ids)
