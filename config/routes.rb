AgentXmpp::Routing::Routes.draw do |map|
  
  #### commands
  map.connect 'uptime/execute',              :controller => 'system', :action => 'uptime'
  map.connect 'file_system_usage/execute',   :controller => 'system', :action => 'file_system_usage'
  
end
