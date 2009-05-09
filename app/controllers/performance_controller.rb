############################################################################################################
class PerformanceController < AgentXmpp::Controller

  #.........................................................................................................
  def stats_summary
    result_for do
      PerformanceCommands.uptime 
    end
    respond_to do |result|
      format.x_data do 
        result.first.to_x_data
      end
    end
    AgentXmpp.logger.info "ACTION: AgentLinux.SystemController\#uptime"
  end
  
############################################################################################################
# UptimeController
end
