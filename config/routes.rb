AgentXmpp::Routing::Routes.draw do |map|
  
  #### commands
  map.connect :command, 'uptime/execute', :controller => 'system', :action => 'uptime'
  
end
