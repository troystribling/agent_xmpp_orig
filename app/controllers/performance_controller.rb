############################################################################################################
class PerformanceController < AgentXmpp::Controller

  #.........................................................................................................
  def cpu_stats
    result_for do
      period = TaskManager.collection_period[:trim_performance_data] || 3600
      PerformanceMonitor.all(:created_at.lt => Time.now - period)
    end
    respond_to do |result|
      format.x_data do 
        result.to_x_data
      end
    end
    AgentXmpp.logger.info "ACTION: PerformanceController\#uptime"
  end
  
############################################################################################################
# UptimeController
end
