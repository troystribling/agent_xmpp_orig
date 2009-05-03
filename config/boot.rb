####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_app_load do

  require 'agent_linux'

  AgentXmpp.log_info "AgentXmpp::BootApp::before_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_app_load do

  AgentXmpp.log_info "AgentXmpp::BootApp::after_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connection_completed do |connection|

  connection.add_delegate(TaskManager)
  
  TaskManager.performance_collection(60)

  AgentXmpp.log_info "AgentXmpp::BootApp::connection_completed"

end
