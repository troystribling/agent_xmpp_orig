AgentXmpp::Routing::Routes.draw do |map|
  
  #### uptime
  map.connect 'uptime/execute', :controller => 'system', :action => 'uptime'
  
end
