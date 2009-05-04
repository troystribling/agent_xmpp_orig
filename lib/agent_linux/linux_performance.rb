############################################################################################################
class LinuxPerformance

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    def cpu_stats(period)      
      LinuxCommands.sar_query("sar -u", period) do |stats|
        created_at = Time.parse("#{stats[0]} #{stats[1]}")
        monitor_class = "cpu"
        ["user", "nice", "system", "iowait", "steal", "idle"].inject(3) do |i, m|
          PerformanceMonitor.new(:monitor => m, :value => stats[i], :monitor_class => monitor_class, :created_at => created_at).save
          puts "#{m}, #{stats[i]}, #{created_at} #{monitor_class}"
          i += 1
        end
      end
    end

  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
