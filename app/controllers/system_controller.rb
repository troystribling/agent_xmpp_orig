############################################################################################################
class SystemController < AgentXmpp::Controller

  #.........................................................................................................
  def uptime
    result_for do
      SystemCommands.uptime 
    end
    respond_to do |result|
      format.x_data do 
        result.to_x_data
      end
    end
    AgentXmpp::logger.info "ACTION: AgentLinux::SystemController\#uptime"
  end
  
############################################################################################################
# UptimeController
end
