##############################################################################################################
AgentXmpp::Boot.before_config_load do

  require 'agent_linux'
  AgentXmpp::Boot.config_load_order = ['config/performance_monitors']
  AgentXmpp.logger.info "AgentXmpp::BootApp.on_app_start"
  
end

##############################################################################################################
AgentXmpp::Boot.before_app_load do

  AgentXmpp.logger.info "AgentXmpp::BootApp.before_app_load"
  
end

##############################################################################################################
AgentXmpp::Boot.after_app_load do

  AgentXmpp.logger.level = Logger::INFO
  LowPassFilter.max_points = 50
  DataMapper.setup(:default, "sqlite3://#{app_dir}/db/agent_linux.db")

  # DataMapper::Logger.new(AgentXmpp.log_file, :debug)
  # DataObjects::Sqlite3.logger = DataObjects::Logger.new(AgentXmpp.log_file, 0)

  AgentXmpp.logger.info "AgentXmpp::BootApp.after_app_load"
  
end

##############################################################################################################
AgentXmpp::Boot.after_connection_completed do |connection|

  connection.add_delegate(TaskManager)  
  TaskManager.performance_collection(10)
  TaskManager.trim_performance_data(3600)
  AgentXmpp.logger.info "AgentXmpp::BootApp.after_connection_completed"

end
