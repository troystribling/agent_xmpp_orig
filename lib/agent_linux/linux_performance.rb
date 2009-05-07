############################################################################################################
class LinuxPerformance

  ###------------------------------------------------------------------------------------------------------
  class << self

    #.........................................................................................................
    @last_vals = {}
    @last_time = {}
        
    #.........................................................................................................
    def cpu      
      data = LinuxProcFiles.stat
      unless @last_vals[:stat].nil?
        dt = (Time.now  - @last_time[:stat]).to_f   
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

    #.........................................................................................................
    def memory      
      save_monitor_hash(LinuxProcFiles.meminfo, "memory", "system")
      data = LinuxProcFiles.vmstat
      save_monitor_hash_delta(data, @last_vals[:vmstat], "memory", "system") unless @last_vals[:vmstat].nil?
      @last_vals[:vmstat] = data
      @last_time[:vmstat] = Time.now 
    end

    #.........................................................................................................
    def storage   
      created_at = Time.now  
      data = LinuxCommands.file_system_usage
      data = [data] unless data.kind_of?(Array)
      data.each do |item|
        PerformanceMonitor.new(:monitor => "used", :value => item[:used], :monitor_class => "storage", :monitor_object => item[:mount], 
                               :created_at => created_at).save
        PerformanceMonitor.new(:monitor => "size", :value => item[:size], :monitor_class => "storage", :monitor_object => item[:mount], 
                               :created_at => created_at).save
      end   
      data = LinuxProcFiles.diskstats
      data.each do |stat|
        save_monitor_hash_delta(stat[:stats], @last_vals[:diskstats][:stats], "storage", stat[:mount]) unless @last_vals[:diskstats].nil?
      end
      @last_vals[:diskstats] = data
      @last_time[:diskstats] = Time.now 
    end

     #.........................................................................................................
     def loadavg      
       save_monitor_hash(LinuxProcFiles.loadavg, "loadavg", "system")
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
