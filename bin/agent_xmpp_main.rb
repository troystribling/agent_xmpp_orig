#!/usr/bin/env ruby

$:.unshift 'lib'
require 'agent_xmpp'

AgentXmpp::Client.new('bill@plan-b.ath.cx', 'pass', 'plan-b.ath.cx').connect
