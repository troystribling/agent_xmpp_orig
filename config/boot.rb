####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.before_app_load do

  require 'agent_linux'
  AgentXmpp.logger.info "AgentXmpp::BootApp.before_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_app_load do

  AgentXmpp.logger.level = Logger::DEBUG
  DataMapper.setup(:default, "sqlite3://#{app_dir}/db/agent_linux.db")
  # DataMapper::Logger.new(AgentXmpp.log_file, :debug)
  # DataObjects::Sqlite3.logger = DataObjects::Logger.new(AgentXmpp.log_file, 0)
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_app_load"
  
end

####------------------------------------------------------------------------------------------------------
AgentXmpp::Boot.after_connection_completed do |connection|

  connection.add_delegate(TaskManager)  
  TaskManager.performance_collection(10)
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connection_completed"

end
