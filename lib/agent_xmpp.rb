module AgentXmpp
  AGENT_XMPP_VERSION = '0.0'
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.to_s.strip
end

require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'xmpp4r/version'
require 'xmpp4r/command/iq/command'
require 'active_support'
require 'eventmachine'
require 'evma_xmlpushparser'

require 'xmpp4r_patches'

require 'agent_xmpp/logger'
require 'agent_xmpp/parser'
require 'agent_xmpp/connection'
require 'agent_xmpp/client'
require 'agent_xmpp/roster'
require 'agent_xmpp/controller'
require 'agent_xmpp/format'
