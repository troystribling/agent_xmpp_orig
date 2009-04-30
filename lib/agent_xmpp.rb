module AgentXmpp
  AGENT_XMPP_VERSION = '0.0'
  AGENT_XMPP_NAME = 'AgentXMPP'
  OS_VERSION = IO.popen('uname -sr').readlines.to_s.strip
end

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

require 'agent_xmpp/client/parser'
require 'agent_xmpp/client/connection'
require 'agent_xmpp/client/client'

require 'agent_xmpp/utils/roster'
require 'agent_xmpp/utils/logger'

require 'agent_xmpp/app/format'
require 'agent_xmpp/app/boot'
require 'agent_xmpp/app/view'
require 'agent_xmpp/app/controller'
require 'agent_xmpp/app/map'
require 'agent_xmpp/app/routes'
require 'agent_xmpp/app/chat_message_body_controller'
