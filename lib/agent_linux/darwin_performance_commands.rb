############################################################################################################
class DarwinPerformanceCommands

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def cpu_stats(period)
      @@last_cpu_stat ||= Time.now - period
      current_time = Time.now
      stats = `sar -u`.split("\n")[3..-2].collect{|s| s.split(/\s+/)}.select do |s|
        data_time = Time.parse(s[0])
        (@@last_cpu_stat <=> data_time).eql?(-1) and (data_time <=> current_time).eql?(-1)
      end 
p stats      
      @@last_cpu_stat = current_time
      AgentXmpp.log_info "DarwinPerformanceCommands.cpu_stats"
    end
      
  ###------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# DarwinPerformanceCommands
end
