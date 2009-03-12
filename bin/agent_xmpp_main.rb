#!/usr/bin/env ruby

$:.unshift 'lib'
require 'agent_xmpp'

AgentXmpp::Client.new('plan-b.ath.cx').connect
