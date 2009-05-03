############################################################################################################
class LinuxCommands

  #.........................................................................................................
  extend SystemCommands
  
  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def cpu_stats(config)      
      sar_query("sar -u", config) do |stats|
        p stats
      end
      AgentXmpp.log_info "LinuxCommands.cpu_stats"
    end

    #.........................................................................................................
    def sar_query(cmd, config)
      query_end = Time.now - config[:lag] || 0
      query_start = query_end - 2 * config[:period]
      stat_cmd = cmd + 
        " -s #{query_start.strftime("%H:%M:%S")} -e #{query_end.strftime("%H:%M:%S")} -f /var/log/sysstat/sa#{query_end.strftime("%d")}"
      stats = `#{stat_cmd}`.split("\n")[3..-2]
      unless stats.nil? 
        yield stats.collect{|s| s.split(/\s+/)}
      end
    end

  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
