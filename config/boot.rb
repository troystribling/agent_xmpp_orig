############################################################################################################
require 'agent_linux'

############################################################################################################
AgentXmpp::Boot.on_boot do |client|

  AgentXmpp.log_info "AgentXmpp::BootApp::on_boot"

  client.connection.add_delegate(PerformanceCollector)
  
  PerformanceCollector.collect(10)

end
