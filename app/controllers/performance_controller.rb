############################################################################################################
class PerformanceController < AgentXmpp::Controller

  #.........................................................................................................
  def cpu_total
    result_for do
      interval = TaskManager.collection_period[:trim_performance_data] || 3600
      PerformanceMonitor.cpu_total_gte_time(Time.now - interval)     
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: PerformanceController\#uptime"
  end
  
############################################################################################################
# UptimeController
end
