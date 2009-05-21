############################################################################################################
class PerformanceController < AgentXmpp::Controller

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def time_series_request_for_monitor(args)
      args = [args] unless args.kind_of?(Array)
      args.each do |monitor| 
        class_eval <<-do_eval
          def #{monitor.to_s}
            result_for_monitor{|interval| PerformanceMonitor.#{monitor.to_s}_gte_time(interval)}
            response_for_monitor("#{monitor.to_s}")
          end
        do_eval
      end
    end
  
    #.........................................................................................................
    def time_series_request_for_all_monitor(args)
      args = [args] unless args.kind_of?(Array)
      args.each do |monitor| 
        class_eval <<-do_eval
          def #{monitor.to_s}
            result_for_monitor{|interval| PerformanceMonitor.#{monitor.to_s}_gte_time_for_object(interval, "all")}
            response_for_monitor("#{monitor.to_s}")
          end
        do_eval
      end
    end
  
  ####------------------------------------------------------------------------------------------------------
  end

  ####------------------------------------------------------------------------------------------------------
  time_series_request_for_monitor LinuxPerformanceMonitors.monitors_for_class(:cpu)
  time_series_request_for_monitor LinuxPerformanceMonitors.monitors_for_class(:memory)
  time_series_request_for_all_monitor LinuxPerformanceMonitors.monitors_for_class(:network)
  time_series_request_for_all_monitor LinuxPerformanceMonitors.monitors_for_class(:storage)
  
####------------------------------------------------------------------------------------------------------
private

  #.........................................................................................................
  def result_for_monitor
    result_for {yield Time.now - (TaskManager.collection_period[:trim_performance_data] || 3600)}
  end

  #.........................................................................................................
  def response_for_monitor(monitor)
    respond_to {|result| LowPassFilter.apply_to(result).to_x_data}
    AgentXmpp.logger.info "ACTION: PerformanceController\##{monitor}"
  end
  
############################################################################################################
# UptimeController
end
