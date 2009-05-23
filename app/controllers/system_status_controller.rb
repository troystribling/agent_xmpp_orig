############################################################################################################
class SystemStatusController < AgentXmpp::Controller

  #.........................................................................................................
  def uptime
    result_for do
      LinuxProcFiles.uptime 
    end
    respond_to do |result|
      up_time = result.first     
      {:booted_on => up_time[:booted_on].strftime("%Y-%m-%d %H:%M:%S"), 
       :up_time => "#{up_time[:up_time][:days]}d, #{up_time[:up_time][:hours]}h, #{up_time[:up_time][:minutes]}m",
       :busy => "#{(100*up_time[:busy]).round}%", :idle => "#{(100*up_time[:idle]).round}%"}.to_x_data
    end
    AgentXmpp.logger.info "ACTION: SystemController\#uptime"
  end

  #.........................................................................................................
  def file_system_usage
    result_for do
      LinuxCommands.file_system_usage 
    end
    respond_to do |result|
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: SystemController\#file_system_usage"
  end
  
  #.........................................................................................................
  def ethernet_interfaces
    result_for do
      LinuxCommands.ethernet_interfaces 
    end
    respond_to do |result|      
      result.to_x_data
    end
    AgentXmpp.logger.info "ACTION: SystemController\#ethernet_intefaces"
  end
 
  #.........................................................................................................
  def active_users
    result_for do
      LinuxCommands.who
    end
    respond_to do |result|
      result.to_x_data
    end
  end
  
############################################################################################################
# UptimeController
end
