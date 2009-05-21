##############################################################################################################
module AgentXmpp
  class Boot
    class << self

      #.........................................................................................................
      def route_for_monitor(args)
        args.each do |monitor| 
          map.connect "#{monitor}/execute", :controller => 'performance', :action => monitor
        end
      end

    end
  end
end

##############################################################################################################
AgentXmpp::Routing::Routes::draw do |map|
  
  #### system commands
  map.connect 'uptime/execute',               :controller => 'system',      :action => 'uptime'
  map.connect 'file_system_usage/execute',    :controller => 'system',      :action => 'file_system_usage'
  map.connect 'ethernet_interfaces/execute',  :controller => 'system',      :action => 'ethernet_interfaces'
  
  #### performance commands
  route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:cpu) 
  route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:memory) 
  route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:storage) 
  route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:network) 
  
end
