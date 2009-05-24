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

      #.........................................................................................................
      def route_system_status(commands)
        commands.each do |command| 
          connect "#{command}/execute", :controller => 'system_status', :action => command
        end
      end

    end
  end
end

##############################################################################################################
AgentXmpp::Routing::Routes.draw do |map|
  
  #### system commands
  map.connect 'uptime/execute',                       :controller => 'system_status',      :action => 'uptime'
  map.route_system_status(LinuxSystemStatusCommands.commands)
  
  #### performance commands
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:cpu) 
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:memory) 
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:storage) 
  map.route_for_monitor LinuxPerformanceMonitors.monitors_for_class(:network) 
  
end
