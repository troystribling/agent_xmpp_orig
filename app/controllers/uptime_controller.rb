############################################################################################################
class UptimeController < AgentXmpp::Controller

  #.........................................................................................................
  def execute
    result_for do
      "hey" 
    end
    respond_to do |result|
      format.data do 
        data_array_of_hashes(result)
      end
    end
    AgentXmpp::logger.info "ACTION: AgentLinux::UptimeController\#execute"
  end
 
  #.........................................................................................................
  def prev
    AgentXmpp::logger.info "ACTION: AgentLinux::UptimeController\#prev"
  end

  #.........................................................................................................
  def next
    AgentXmpp::logger.info "ACTION: AgentLinux::UptimeController\#next"
  end
  
  #.........................................................................................................
  def complete
    AgentXmpp::logger.info "ACTION: AgentLinux::UptimeController\#complete"
  end

  #.........................................................................................................
  def cancel
    AgentXmpp::logger.info "ACTION: AgentLinux::UptimeController\#cancel"
  end
 
############################################################################################################
# UptimeController
end
