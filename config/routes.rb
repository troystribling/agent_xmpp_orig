AgentXmpp::Routing::Routes::draw do |map|
  
  #### system commands
  map.connect 'uptime/execute',               :controller => 'system',      :action => 'uptime'
  map.connect 'file_system_usage/execute',    :controller => 'system',      :action => 'file_system_usage'
  map.connect 'ethernet_interfaces/execute',  :controller => 'system',      :action => 'ethernet_interfaces'
  
  #### performance commands
  map.connect 'cpu_stats/execute',            :controller => 'performance', :action => 'cpu_stats'
  
end
