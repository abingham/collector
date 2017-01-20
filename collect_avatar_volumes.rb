#!/usr/bin/env ruby

require 'date'

# Collects old docker volumes created by the DockerAvatarVolumeRunner
# which creates a volume per kata, and a volume per avatar.

# - - - - - - - - - - - - - - - - - - - - -

# The filter patterns must _NOT_ match the
# name of the katas-data-volume which is
# cyber-dojo-katas-DATA-CONTAINER.

def avatar_pattern
  'cyber_dojo_avatar_volume_runner_avatar'
end

def kata_pattern
  'cyber_dojo_avatar_volume_runner_kata'
end

# - - - - - - - - - - - - - - - - - - - - -

def volume_names(pattern)
  cmd = "docker volume ls --quiet --filter 'name=#{pattern}'"
  `#{cmd}`.split
end

# - - - - - - - - - - - - - - - - - - - - -

def gather_avatar_volume_info(data)
  volume_names(avatar_pattern).each do |volume_name|
    # eg cyber_dojo_avatar_volume_runner_avatar_AC6B15895D_vulture
    parts = volume_name.split('_')
    kata_id = parts[6]     # eg AC6B15895D
    avatar_name = parts[7] # eg vulture
    data[kata_id] ||= []
    data[kata_id] << avatar_name
  end
end

# - - - - - - - - - - - - - - - - - - - - -

def gather_kata_volume_info(data)
  volume_names(kata_pattern).each do |volume_name|
    # eg cyber_dojo_avatar_volume_runner_kata_AC6B15895D
    parts = volume_name.split('_')
    kata_id = parts[6] # eg AC6B15895D
    data[kata_id] ||= []
  end
end

# - - - - - - - - - - - - - - - - - - - - -

def collect_old_avatar_volumes(data)
  kata_ids = data.keys
  kata_ids.each do |kata_id|
    data[kata_id].each do |avatar_name|
      days_old = last_modified(kata_id, avatar_name)
      puts "DockerAvatarVolumeRunner: #{kata_id} - #{avatar_name} - #{days_old} days old"
      if days_old >= 7
        avatar_collect(kata_id, avatar_name)
        data[kata_id].delete(avatar_name)
      end
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - -

def last_modified(kata_id, avatar_name)
  name = [ avatar_pattern, kata_id, avatar_name ].join('_')
  sandbox = "/sandboxes/#{avatar_name}"
  # find the most recently modified file. %Y == seconds since epoch
  cmd = [ 'docker run',
          '--rm',
          '-it',
          "--volume #{name}:#{sandbox}:ro",
          'cyberdojo/collector',
          "sh -c 'find #{sandbox} -type f -print0 | xargs -0 stat -c %Y | sort -rn | head -1'"
  ].join(space = ' ')
  sse = `#{cmd}`  # eg 1484774952
  most_recent = Time.at(sse.to_i).to_datetime # eg 2017-01-18T21:29:12+00:00
  (DateTime.now - most_recent).to_i # eg 1
end

def avatar_collect(kata_id, avatar_name)
  name = [ avatar_pattern, kata_id, avatar_name ].join('_')
  cmd = "docker volume rm #{name}"
  `#{cmd}`
end

# - - - - - - - - - - - - - - - - - - - - -

def collect_old_kata_volumes(data)
  # how can I find old kata-volumes if no animals have started?
  # If you create a volume, then mount it into a container to
  # a particular dir, what date does the dir have?
  # Jan 18 16:22 sandboxes
  # which was run at 16:55
  #
  # So...
  # if any avatar volumes remain after collecting
  #    retain the kata-volume
  # else if the date of the kata-volume is 7days old
  #    delete the kata-volume  (it can easily be resurrected)
  #
  #
  # Or I could just delete kata-volumes if there are no animal-volumes left
  # That might delete just created kata-volumes
end

# - - - - - - - - - - - - - - - - - - - - -

data = {}

gather_avatar_volume_info(data)
gather_kata_volume_info(data)

collect_old_avatar_volumes(data)
collect_old_kata_volumes(data)

