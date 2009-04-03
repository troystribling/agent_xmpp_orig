#!/usr/bin/env ruby

#---------------------------------------------------------------------------------------------------------
$:.unshift 'lib'
require 'optparse'
require 'agent_xmpp'

#---------------------------------------------------------------------------------------------------------
config_file = 'config/agent.yml'
log_file = STDOUT
OptionParser.new do |opts|
  opts.banner = 'Usage: agent_xmpp.rb -f config.yml'
  opts.separator ''
  opts.on('-f', '--file config.yml', 'YAML agent configuration file') {|f| config_file = f}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| log_file = f}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

#---------------------------------------------------------------------------------------------------------
config = File.open(config_file) {|yf| YAML::load(yf)}
AgentXMPP::logger = Logger.new(log_file, 10, 1024000) unless log_file.eql?(STDOUT)
AgentXmpp::Client.new(config).connect
