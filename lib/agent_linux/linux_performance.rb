############################################################################################################
class LinuxPerformance

  #.........................................................................................................
  @last_vals = {}
  @last_time = {}
      
  ###------------------------------------------------------------------------------------------------------
  class << self

    #.........................................................................................................
    def cpu      
      data = LinuxProcFiles.stat
      created_at = Time.now
      unless @last_vals[:stat].nil?
        dt = (created_at - @last_time[:stat]).to_f   
        data[:cpu].each_pair do |mon, val|
          dv = 100.0*((val - @last_vals[:stat][:cpu][mon])/dt).precision
          PerformanceMonitor.new(:monitor => mon.to_s, :value => dv, :monitor_class => "cpu", :monitor_object => "system", 
                                 :created_at => created_at).save unless dv < 0
        end
        save_monitor_hash_derivative(data[:cpu_procs], @last_vals[:stat][:cpu_procs], @last_time[:stat], "cpu", "system")
      end
      save_monitor_hash(data[:procs], "cpu", "system")
      @last_vals[:stat] = data
      @last_time[:stat] = created_at
    end

    #.........................................................................................................
    def memory      
      save_monitor_hash(LinuxProcFiles.meminfo, "memory", "system")
      data = LinuxProcFiles.vmstat
      save_monitor_hash_derivative(data, @last_vals[:vmstat], @last_time[:vmstat], "memory", "system") unless @last_vals[:vmstat].nil?
      @last_vals[:vmstat] = data
      @last_time[:vmstat] = Time.now 
    end

    #.........................................................................................................
    def storage   
      data = LinuxCommands.file_system_usage
      data = [data] unless data.kind_of?(Array)
      created_at = Time.now  
      data.each do |item|
        PerformanceMonitor.new(:monitor => "used", :value => storage_used_to_f(item[:used]), :monitor_class => "storage", :monitor_object => item[:mount], 
                               :created_at => created_at).save
        PerformanceMonitor.new(:monitor => "size", :value => storage_size_to_f(item[:size]), :monitor_class => "storage", :monitor_object => item[:mount], 
                               :created_at => created_at).save
      end   
      data = LinuxProcFiles.diskstats      
      unless @last_vals[:diskstats].nil?
        data.each do |stats|
          last_stats = @last_vals[:diskstats].select{|row| row[:mount].eql?(stats[:mount])}.first
          unless last_stats.nil?
            save_monitor_hash_derivative(stats[:vals], last_stats[:vals], @last_time[:diskstats], "storage", stats[:mount])
            storage_service_time(stats[:vals], last_stats[:vals], stats[:mount])
          end
        end
      end
      @last_vals[:diskstats] = data
      @last_time[:diskstats] = created_at      
    end

    #.........................................................................................................
    def net
      data = LinuxProcFiles.net_dev      
      unless @last_vals[:net_dev].nil?
        data.each do |stats|
          last_stats = @last_vals[:net_dev].select{|row| row[:if].eql?(stats[:if])}.first
          save_monitor_hash_derivative(stats[:vals], last_stats[:vals], @last_time[:net_dev], "net", stats[:if]) unless last_stats.nil?
        end
      end
      @last_vals[:net_dev] = data
      @last_time[:net_dev] = Time.now 
    end
  
    #.........................................................................................................
    def loadavg      
      save_monitor_hash(LinuxProcFiles.loadavg, "loadavg", "system")
    end

    #.........................................................................................................
    #.........................................................................................................
    def storage_used_to_f(val)
      val.chomp("%").to_f
    end

    #.........................................................................................................
    def service_time(busy, dv)
      busy > 0.0 ? (busy / dv).precision : 0.0;
    end

    #.........................................................................................................
    def storage_service_time(stats, last_stats, monitor_object)
      created_at = Time.now   
      dt = (created_at - @last_time[:diskstats]).to_f 
      dt_read = (stats[:time_reading] - last_stats[:time_reading])
      dt_write = (stats[:time_writing] - last_stats[:time_writing])
      dread = stats[:reads] - last_stats[:reads]
      dwrite = stats[:writes] - last_stats[:writes]
      busy_reading = (0.1 * dt_read / dt).precision
      busy_writing = (0.1 * dt_write / dt).precision
      busy = busy_reading + busy_writing
      service_time_reading = service_time(dt_read, dread)
      service_time_writing = service_time(dt_write, dwrite)
      service_time_rw = service_time(dt_read + dt_write, dread + dwrite)
      PerformanceMonitor.new(:monitor => "busy_reading", :value => busy_reading, :monitor_class => "storage", :monitor_object => monitor_object, 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "busy_writing", :value => busy_writing, :monitor_class => "storage", :monitor_object => monitor_object, 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "busy", :value => busy, :monitor_class => "storage", :monitor_object => monitor_object, 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "service_time_reading", :value => service_time_reading, :monitor_class => "storage", :monitor_object => monitor_object, 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "service_time_writing", :value => service_time_writing, :monitor_class => "storage", :monitor_object => monitor_object, 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "service_time", :value => service_time_rw, :monitor_class => "storage", :monitor_object => monitor_object, 
                             :created_at => created_at).save
    end

    #.........................................................................................................
    def storage_size_to_f(val)
      case val
      when /T$/ : val.chomp("T").to_f * 1024**2
      when /G$/ : val.chomp("G").to_f * 1024
      when /M$/ : val.chomp("M").to_f 
      when /K$/ : (val.chomp("K").to_f / 1024).precision
      else
        val.to_f
      end
    end

    #.........................................................................................................
    def save_monitor_hash_derivative(current_data, last_data, last_time, monitor_class , monitor_object)
      created_at = Time.now  
      dt = (created_at - last_time)
      current_data.each_pair do |mon, val|
        delta = (val - last_data[mon])
        dv_dt = (delta / dt).precision
        PerformanceMonitor.new(:monitor => mon.to_s, :value => dv_dt, :monitor_class => monitor_class, :monitor_object => monitor_object, 
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
