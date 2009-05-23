##############################################################################################################
module AgentXmpp
  module Routing
    class Map

      #.........................................................................................................
      def route_for_monitor(monitors)
        monitors.each do |monitor| 
          connect "#{monitor}/execute", :controller => 'performance', :action => monitor
        end
      end

    end
  end
end

##############################################################################################################
AgentXmpp::Routing::Routes.draw do |map|
  
  #### system commands
  map.connect 'uptime/execute',               :controller => 'system_status',      :action => 'uptime'
  map.connect 'file_system_usage/execute',    :controller => 'system_status',      :action => 'file_system_usage'
  map.connect 'ethernet_interfaces/execute',  :controller => 'system_status',      :action => 'ethernet_interfaces'
  map.connect 'active_users/execute',          :controller => 'system_status',      :action => 'active_users'
  
  #### performance commands
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:cpu) 
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:memory) 
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:storage) 
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:network) 
  
end
