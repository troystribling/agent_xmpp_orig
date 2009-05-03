#!/usr/bin/env ruby

####------------------------------------------------------------------------------------------------------
$:.unshift 'lib/patches'
$:.unshift 'lib'

####------------------------------------------------------------------------------------------------------
require 'optparse'
require 'agent_xmpp'
require 'find'

####------------------------------------------------------------------------------------------------------
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

####------------------------------------------------------------------------------------------------------
def load(path)
  Find.find(path) do |file_path|
    if file = /(.*)\.rb$/.match(file_path)
      require file.to_a.last
    end
  end
end

load('config')

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.call_before_app_load if AgentXmpp::Boot.respond_to?(:call_before_app_load)

####------------------------------------------------------------------------------------------------------
load('app/models')
load('app/controllers')

####------------------------------------------------------------------------------------------------------
DataMapper.setup(:default, "sqlite3://../db/agent_xmpp.db")

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.call_after_app_load if AgentXmpp::Boot.respond_to?(:call_after_app_load)

####------------------------------------------------------------------------------------------------------

####------------------------------------------------------------------------------------------------------
config = File.open(config_file) {|yf| YAML::load(yf)}
AgentXmpp::logger = Logger.new(log_file, 10, 1024000) unless log_file.eql?(STDOUT)
AgentXmpp::Client.new(config).connect
