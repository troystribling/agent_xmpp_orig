############################################################################################################
class SystemController < AgentXmpp::Controller

  #.........................................................................................................
  def uptime
    result_for do
      SystemCommands.uptime 
    end
    respond_to do |result|
      format.x_data do 
        result.first.to_x_data
      end
    end
    AgentXmpp.log_info "ACTION: AgentLinux.SystemController\#uptime"
  end

  #.........................................................................................................
  def file_system_usage
    result_for do
      SystemCommands.file_system_usage 
    end
    respond_to do |result|
      format.x_data do 
        result.to_x_data
      end
    end
    AgentXmpp.log_info "ACTION: AgentLinux.SystemController\#file_system_usage"
  end
  
############################################################################################################
# UptimeController
end
