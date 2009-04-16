AgentXmpp::Routing::Routes.draw do |map|
  
  #### commands
  map.connect 'uptime/execute', :controller => 'system', :action => 'uptime'
  
end
