#!/usr/bin/env ruby

require "date"
require "optparse"

history_log = '/var/log/apt/history.log'

class AptHistory
  attr_reader :start_date, :command_line, :requested_by, :action, :packages, :end_date, :error

  def initialize(start_date: nil, command_line: '',
    requested_by: '', action: nil, packages: [], end_date: nil, error: '')
  @start_date, @command_line, @requested_by, @action, @packages, @end_date, @error =
    start_date, command_line, requested_by, action, packages, end_date, error
  end

  def self.read(filename)
    p filename
    histories = []
    start_date, command_line, requested_by, action, packages, error, end_date = nil
    File.readlines(filename).each.with_index do |s, i|
      s.chomp!
      next if s.empty?
      key, value = s.split(/:\s+/)
      case key
      when 'Start-Date'
        start_date = DateTime.parse value
      when 'Commandline'
        command_line = value
      when 'Requested-By'
        requested_by = value
      when 'Install', 'Upgrade', 'Purge', 'Remove'
        action = key
        packages = value.split(',\s+')
      when 'Error'
        error = value
      when 'End-Date'
        end_date = DateTime.parse value
        ah = AptHistory.new(start_date: start_date, command_line: command_line, requested_by: requested_by, action: action, packages: packages, end_date: end_date, error: error)
        histories << ah
      else
        $stderr.puts "#{filename}: #{i}: warning: unknown keyword -- <#{key}>"
      end
    end
    histories
  end
end


his = AptHistory.read(history_log)
his.each do |h|
  puts "#{h.start_date.strftime '%F %T'}: #{h.command_line}"
end