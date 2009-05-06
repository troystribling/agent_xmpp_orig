############################################################################################################
class LinuxPerformance

  #.........................................................................................................
  @last_vals = {}
  @last_time = {}

  ###------------------------------------------------------------------------------------------------------
  class << self
        
    #.........................................................................................................
    def cpu      
      LinuxProcFiles.stat do |data|
        created_at = Time.now  
        unless @last_vals[:stat].nil?
          dt = (created_at - @last_time[:stat]).to_f   
          data[:cpu].each_pair do |mon, val|
            dv = 100.0*((val - @last_vals[:stat][:cpu][mon])/dt).precision
            PerformanceMonitor.new(:monitor => mon.to_s, :value => dv, :monitor_class => "cpu", :monitor_object => "system", 
                                   :created_at => created_at).save unless dv < 0
          end
          save_monitor_hash_delta(data[:cpu_procs], @last_vals[:stat][:cpu_procs], "cpu", "system")
        end
        save_monitor_hash(data[:procs], "cpu", "system")
        @last_vals[:stat] = data
        @last_time[:stat] = created_at
      end
    end

    #.........................................................................................................
    def memory      
      LinuxProcFiles.meminfo do |data|
        save_monitor_hash(data, "memory", "system")
      end
      LinuxProcFiles.vmstat do |data|
        save_monitor_hash_delta(data, @last_vals[:vmstat], "memory", "system") unless @last_vals[:vmstat].nil?
        @last_vals[:vmstat] = data
        @last_time[:vmstat] = Time.now 
      end
    end

     #.........................................................................................................
     def loadavg      
       LinuxProcFiles.loadavg do |data|
         save_monitor_hash(data, "loadavg", "system")
       end
     end

     #.........................................................................................................
     def save_monitor_hash_delta(current_data, last_data, monitor_class , monitor_object)
        created_at = Time.now  
        current_data.each_pair do |mon, val|
          delta = (val - last_data[mon]).precision
          PerformanceMonitor.new(:monitor => mon.to_s, :value => delta, :monitor_class => monitor_class, :monitor_object => monitor_object, 
                                 :created_at => created_at).save
        end
     end

    #.........................................................................................................
    def save_monitor_hash(data, monitor_class , monitor_object)
       created_at = Time.now  
       data.each_pair do |mon, val|
         PerformanceMonitor.new(:monitor => mon.to_s, :value => val.to_f, :monitor_class => monitor_class, :monitor_object => monitor_object, 
                                :created_at => created_at).save
       end
    end
  
  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
