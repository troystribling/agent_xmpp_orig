############################################################################################################
class DarwinCommands

  #.........................................................................................................
  extend SystemCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def cpu_stats(config)
      sar_query("sar -u", config) do |stats|
        p stats
      end
      AgentXmpp.log_info "DarwinCommands.cpu_stats"
    end

    #.........................................................................................................
    def sar_query(cmd, config)
      query_end = Time.now - config[:lag] || 0
      query_start = query_end - config[:period]
      stat_rows = `#{cmd}`.split("\n")[3..-2]
      unless stat_rows.nil? 
        stats = stat_rows.collect{|s| s.split(/\s+/)}.select do |p| 
          ((Time.parse(p[0]) <=> query_start) > -1) and ((query_end <=> Time.parse(p[0])) > -1)
        end
        unless stats.empty?
          yield stats
        else
        end
      else
      end
    end
      
  ###------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# DarwinCommands
end
