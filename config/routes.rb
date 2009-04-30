AgentXmpp::Routing::Routes::draw do |map|
  
  #### system commands
  map.connect 'uptime/execute',             :controller => 'system',      :action => 'uptime'
  map.connect 'file_system_usage/execute',  :controller => 'system',      :action => 'file_system_usage'
  
  #### performance commands
  map.connect 'stats_summary/execute',      :controller => 'performance', :action => 'stats_summary'
  
end
