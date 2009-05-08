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
      data.each do |stats|
        unless @last_vals[:diskstats].nil?
          last_stats = @last_vals[:diskstats].select{|row| row[:mount].eql?(stats[:mount])}.first
          save_monitor_hash_delta(stats[:stats], last_stats[:stats], "storage", stats[:mount])
          storage_service_time(stats[:stats])
        end
      end
      @last_vals[:diskstats] = data
      @last_time[:diskstats] = created_at      
    end

    #.........................................................................................................
    def net
      data = LinuxProcFiles.net_dev      
      data.each do |stats|
        unless @last_vals[:net_dev].nil?
          last_stats = @last_vals[:net_dev].select{|row| row[:if].eql?(stats[:if])}.first
          save_monitor_hash_delta(stats[:stats], last_stats[:stats], "net", stats[:if])
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
      busy > 0 ? dv / busy : 0;
    end

    #.........................................................................................................
    def storage_service_time(stats)
      dt = (Time.now - @last_time[:stat]).to_f 
      busy_reading = (stats[:time_reading] - @last_time[:stat][:time_reading]) / dt
      busy_writing = (stats[:time_writing] - @last_time[:stat][:time_writing]) / dt
      busy = busy_reading + busy_writing
      service_time_reading = service_time(busy_reading, stats[:reads] - @last_time[:stat][:reads])
      service_time_writing = service_time(busy_writing, stats[:writes] - @last_time[:stat][:writes])
      service_time_rw = service_time(busy, stats[:writes] + stats[:reads] - @last_time[:stat][:writes] - @last_time[:stat][:writes])
      PerformanceMonitor.new(:monitor => "busy_reading", :value => busy_reading, :monitor_class => "storage", :monitor_object => stat[:mount], 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "busy_writing", :value => busy_writing, :monitor_class => "storage", :monitor_object => stat[:mount], 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "busy", :value => busy, :monitor_class => "storage", :monitor_object => stat[:mount], 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "service_time_reading", :value => service_time_reading, :monitor_class => "storage", :monitor_object => stat[:mount], 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "service_time_writing", :value => service_time_writing, :monitor_class => "storage", :monitor_object => stat[:mount], 
                             :created_at => created_at).save
      PerformanceMonitor.new(:monitor => "service_time", :value => service_time_rw, :monitor_class => "storage", :monitor_object => stat[:mount], 
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
    def save_monitor_hash_delta(current_data, last_data, monitor_class , monitor_object)
      created_at = Time.now  
      current_data.each_pair do |mon, val|
puts "mon=#{mon}, val=#{val}, last_data=#{last_data[mon]}"          
        delta = (val - last_data[mon]).precision
puts "delta=#{delta}"          
        PerformanceMonitor.new(:monitor => mon.to_s, :value => delta, :monitor_class => monitor_class, :monitor_object => monitor_object, 
                               :created_at => created_at).save
      end
    end

    #.........................................................................................................
    def save_monitor_hash(data, monitor_class , monitor_object)
      created_at = Time.now  
      data.each_pair do |mon, val|
puts "mon=#{mon}, val=#{val}"          
       PerformanceMonitor.new(:monitor => mon.to_s, :value => val.to_f, :monitor_class => monitor_class, :monitor_object => monitor_object, 
                              :created_at => created_at).save
      end
    end
  
  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
