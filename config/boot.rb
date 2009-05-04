####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_app_load do

  require 'agent_linux'

  AgentXmpp.log_info "AgentXmpp::BootApp.before_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_app_load do

  DataMapper.setup(:default, "sqlite3://#{app_dir}/db/agent_linux.db")
  DataMapper.auto_migrate!  
  AgentXmpp.log_info "AgentXmpp::BootApp.after_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connection_completed do |connection|

  connection.add_delegate(TaskManager)
  
  TaskManager.performance_collection(10)

  AgentXmpp.log_info "AgentXmpp::BootApp.after_connection_completed"

end
