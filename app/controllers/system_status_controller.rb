############################################################################################################
class SystemStatusController < AgentXmpp::Controller

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def system_status_request_for_commands(args)
      args = [args] unless args.kind_of?(Array)
      args.each do |command| 
        class_eval <<-do_eval
          def #{command.to_s}
            result_for {LinuxCommands.#{command.to_s}}
            response_for_status_request("#{command.to_s}")
          end
        do_eval
      end
    end
  
  end
  ####------------------------------------------------------------------------------------------------------
  
  #.........................................................................................................
  system_status_request_for_commands(LinuxSystemStatusCommands.commands)

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
    AgentXmpp.logger.info "ACTION: SystemStatusController\#uptime"
  end
  
####------------------------------------------------------------------------------------------------------
private

  #.........................................................................................................
  def response_for_status_request(monitor)
    respond_to {|result| result.to_x_data}
    AgentXmpp.logger.info "ACTION: SystemStatusController\##{monitor}"
  end  
  
############################################################################################################
# SystemStatusController
end
