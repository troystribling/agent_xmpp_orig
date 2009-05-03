############################################################################################################
class DarwinCommands

  #.........................................................................................................
  extend SystemCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def cpu_stats(period)
      @@cpu_stats_start ||= Time.now - period
      @@cpu_stats_start = sar_query("sar -u", @@cpu_stats_start) do |stats|
        p stats
      end
p @@cpu_stats_start      
      AgentXmpp.log_info "DarwinCommands.cpu_stats"
    end

    #.........................................................................................................
    def sar_query(cmd, query_start)
      query_end = Time.now
p query_start
p query_end      
      stat_rows = `#{cmd}`.split("\n")[3..-2]
      unless stat_rows.nil? 
        stats = stat_rows.collect{|s| s.split(/\s+/)}.select do |p| 
          ((Time.parse(p[0]) <=> query_start) > -1) and ((query_end <=> Time.parse(p[0])) > -1)
        end
p stats        
        unless stats.empty?
          yield stats
          query_end
        else
          query_start
        end
      else
        query_start
      end
    end
      
  ###------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# DarwinCommands
end
