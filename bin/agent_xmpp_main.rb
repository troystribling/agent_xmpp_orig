#!/usr/bin/env ruby

$:.unshift 'lib'

require 'rubygems'
require 'eventmachine'
require 'agent_xmpp'

EventMachine::run do
  EventMachine::connect('plan-b.ath.cx', 5222, AgentXmpp::Connection)
end