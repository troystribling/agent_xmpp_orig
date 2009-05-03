############################################################################################################
class LinuxCommands

  #.........................................................................................................
  extend SystemCommands
  
  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def cpu_stats(period)
      sar_query("sar -u", 2 * period) do |stats|
        p stats
      end
      AgentXmpp.log_info "LinuxCommands.cpu_stats"
    end

    #.........................................................................................................
    def sar_query(cmd, period)
      query_end = Time.now
      query_start = query_end - period
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
