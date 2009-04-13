############################################################################################################
class UptimeController < AgentXmpp::Controller

  #.........................................................................................................
  def execute
    result_for do
      "hey" 
    end
    respond_to do |result|
      format.x_data do 
        result.to_x_data
      end
    end
    AgentXmpp::logger.info "ACTION: AgentLinux::UptimeController\#execute"
  end
  
############################################################################################################
# UptimeController
end
