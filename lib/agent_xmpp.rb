$:.unshift 'lib/patches'

module AgentXmpp
  AGENT_XMPP_VERSION = '0.0'
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.to_s.strip
end

require 'find'

require 'rubygems'
require 'eventmachine'
require 'evma_xmlpushparser'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'xmpp4r/version'
require 'xmpp4r/dataforms'
require 'xmpp4r/command/iq/command'
require 'datamapper'

require 'patches'

require 'agent_xmpp/app'
require 'agent_xmpp/client'
require 'agent_xmpp/utils'
