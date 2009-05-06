############################################################################################################
class LinuxProcFiles

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.......................................................................................................
    def stat
      cat("/proc/stat") do |rows|
        cpu_row = rows[0].split(/\s+/)[1..-1].collect{|c| c.to_f/100.0}
        cpu = {:user => cpu_row[0], :nice => cpu_row[1], :system => cpu_row[2], :idle => cpu_row[3], :iowait => cpu_row[4],
               :irq => cpu_row[5], :softirq => cpu_row[6], :steal => cpu_row[7], :guest => cpu_row[8], 
               :total => cpu_row[0] + cpu_row[1] + cpu_row[2] + cpu_row[4] + cpu_row[5] + cpu_row[6] + cpu_row[7] + cpu_row[8]} 
        ncpus = cpu_count   
        stat_data = {:cpu       => cpu, 
                     :cpu_procs => {:ctxt => mon_val(rows[2 + ncpus]), :processes => mon_val(rows[4 + ncpus])}, 
                     :procs     => {:procs_running => mon_val(rows[5 + ncpus]), :procs_blocked => mon_val(rows[6 + ncpus])}}
        yield stat_data        
      end
    end

    #.......................................................................................................
    def meminfo
      cat("/proc/meminfo") do |rows|
        meminfo_data = {}
        meminfo_data[:mem_total]    = mon_val(row[0])
        meminfo_data[:mem_free]     = mon_val(row[1])
        meminfo_data[:buffers]      = mon_val(row[2])
        meminfo_data[:cached]       = mon_val(row[3])
        meminfo_data[:active]       = mon_val(row[4])
        meminfo_data[:inactive]     = mon_val(row[5])
        meminfo_data[:swap_total]   = mon_val(row[11])
        meminfo_data[:swap_free]    = mon_val(row[12])
        meminfo_data[:swap_used]    = meminfo_data[:swap_total] - meminfo_data[:swap_free]
        meminfo_data[:total_cached] = meminfo_data[:buffers] - meminfo_data[:cached]
        meminfo_data[:process_used] = meminfo_data[:mem_total] - meminfo_data[:mem_free] - meminfo_data[:total_cached] 
        yield meminfo_data        
      end
    end

    #.......................................................................................................
    def vmstat
      cat("/proc/vmstat") do |rows|
        vmstat_data = {}
        page_size = LinuxCommands.get_memory_page_size
        yield {:pgpgin => mon_val(row[15]) * page_size, :pgpgin => mon_val(row[16]) * page_size
               :pswpin => mon_val(row[17]) * page_size, :pswpout => mon_val(row[18]) * page_size
               :pgfault => mon_val(row[26]), :pgfault => mon_val(row[27])}         
      end
    end

    #.......................................................................................................
    def loadavg
      cat("/proc/loadavg") do |rows|        
        vals = rows[0].split(/s+/)[0..-2].collect{|v| v.to_f}
        yield {:one_minute => vals[0], :five_minute => vals[1], :fifteen_minue => vals[2]}        
      end
    end

    #......................................................................................................
    def cpu_count
      cat("/proc/cpuinfo") do |rows|
        rows.inject(0) {|n, r| /^processor/.match(r) ? n + 1 : n}
      end
    end  

    #......................................................................................................
    def cat(file_name)
      yield `cat #{file_name}`.split("\n")
    end  
      
    #........................................................................................................
    def mon_val(row)
      row.split(/\s+/)[1].to_f
    end

  ###--------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxProcFiles
end
