############################################################################################################
class SystemController < AgentXmpp::Controller

  #.........................................................................................................
  def uptime
    result_for do
      LinuxCommands.uptime 
    end
    respond_to do |result|
      result.first.to_x_data
    end
    AgentXmpp.logger.info "ACTION: SystemController\#uptime"
  end

  #.........................................................................................................
  def file_system_usage
    result_for do
      LinuxCommands.file_system_usage 
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: SystemController\#file_system_usage"
  end
  
  #.........................................................................................................
  def ethernet_interfaces
    result_for do
      LinuxCommands.ethernet_interfaces 
    end
    respond_to do |result|      
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: SystemController\#ethernet_intefaces"
  end
  
  
############################################################################################################
# UptimeController
end
