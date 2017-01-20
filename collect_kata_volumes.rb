#!/usr/bin/env ruby

require 'date'
require_relative 'days_since_used_kata_volume'

# Collects old docker volumes created by
# the DockerKataVolumeRunner
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
    days = days_since_used_kata_volume(kata_id)
    puts "DockerKataVolumeRunner: #{kata_id} - #{days} days old"
    if days >= 7
      kata_collect(kata_id)
    end
  end
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
