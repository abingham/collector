#!/usr/bin/env ruby

require 'date'
require_relative 'assert_exec'

include AssertExec

def space; ' '; end
def sandboxes; '/sandboxes'; end

def runner_volume_send_into_past(name, days)
  past = (DateTime.now - days).strftime('%Y%m%d%H%M.%S')
  shell_cmd = [
    'docker run',
      '--rm',
      "--volume #{name}:#{sandboxes}:rw",
      'cyberdojo/collector',
      "sh -c 'touch -d #{past} #{sandboxes}'"
  ].join(space)
  assert_exec shell_cmd
end

name=ARGV[0]
days=ARGV[1].to_i
runner_volume_send_into_past name, days
