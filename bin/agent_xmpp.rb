#!/usr/bin/env ruby

####------------------------------------------------------------------------------------------------------
$:.unshift 'lib'

####------------------------------------------------------------------------------------------------------
require 'optparse'
require 'agent_xmpp'
require 'config/boot'

####------------------------------------------------------------------------------------------------------
config_file = 'config/agent.yml'
AgentXmpp.log_file = "log/agent_xmpp.log"
OptionParser.new do |opts|
  opts.banner = 'Usage: agent_xmpp.rb -f config.yml'
  opts.separator ''
  opts.on('-f', '--file config.yml', 'YAML agent configuration file') {|f| config_file = f}
  opts.on('-l', '--logfile file.log', 'name of logfile') {|f| AgentXmpp.log_file = f}
  opts.on_tail('-h', '--help', 'Show this message') {
    puts opts
    exit
  }
  opts.parse!(ARGV)
end

####------------------------------------------------------------------------------------------------------
AgentXmpp.logger = Logger.new(AgentXmpp.log_file, 10, 1024000)
AgentXmpp.logger.info "STARTING AgentXmpp"

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.call_before_config_load if AgentXmpp::Boot.respond_to?(:call_before_config_load)

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.load('config', {:exclude => ['config/boot'], :ordered_load => AgentXmpp::Boot.config_load_order})

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.call_before_app_load if AgentXmpp::Boot.respond_to?(:call_before_app_load)

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.load('app/models', {:ordered_load => AgentXmpp::Boot.app_load_order})
AgentXmpp::Boot.load('app/controllers')

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.call_after_app_load if AgentXmpp::Boot.respond_to?(:call_after_app_load)

####------------------------------------------------------------------------------------------------------
config = File.open(config_file) {|yf| YAML::load(yf)}
AgentXmpp::Client.new(config).connect
