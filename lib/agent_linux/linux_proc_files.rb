############################################################################################################
class LinuxProcFiles

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.......................................................................................................
    def stat
      rows = LinuxCommands.cat("/proc/stat")
        cpu_row = rows[0].split(/\s+/)[1..-1].collect{|c| c.to_f/100.0}
        cpu = {:user => cpu_row[0], :nice => cpu_row[1], :system => cpu_row[2], :idle => cpu_row[3], :iowait => cpu_row[4],
               :irq => cpu_row[5], :softirq => cpu_row[6], :steal => cpu_row[7], :guest => cpu_row[8], 
               :total => cpu_row[0] + cpu_row[1] + cpu_row[2] + cpu_row[4] + cpu_row[5] + cpu_row[6] + cpu_row[7] + cpu_row[8]} 
        ncpus = cpu_count   
        {:cpu       => cpu, 
         :cpu_procs => {:ctxt => mon_val(rows[2 + ncpus]), :processes => mon_val(rows[4 + ncpus])}, 
         :procs     => {:procs_running => mon_val(rows[5 + ncpus]), :procs_blocked => mon_val(rows[6 + ncpus])}}
    end

    #.......................................................................................................
    def meminfo
      rows = LinuxCommands.cat("/proc/meminfo")
      {:mem_total     => mon_val(rows[0]),
       :mem_free      => mon_val(rows[1]),
       :buffers       => mon_val(rows[2]),
       :cached        => mon_val(rows[3]),
       :active        => mon_val(rows[4]),
       :inactive      => mon_val(rows[5]),
       :swap_total    => mon_val(rows[11]),
       :swap_free     => mon_val(rows[12]),
       :swap_used     => mon_val(rows[11]) - mon_val(rows[12]),
       :total_cached  => mon_val(rows[2]) - mon_val(rows[3]),
       :process_used  => mon_val(rows[0]) - mon_val(rows[1]) - mon_val(rows[2]) - mon_val(rows[3])}
    end

    #.......................................................................................................
    def vmstat
      rows = LinuxCommands.cat("/proc/vmstat")
      page_size = LinuxCommands.get_memory_page_size
      {:pgpgin => mon_val(rows[15]) * page_size, :pgpgin => mon_val(rows[16]) * page_size
       :pswpin => mon_val(rows[17]) * page_size, :pswpout => mon_val(rows[18]) * page_size
       :pgfault => mon_val(rows[26]), :pgfault => mon_val(rows[27])}         
    end

    #.......................................................................................................
    def loadavg
      vals = LinuxCommands.cat("/proc/loadavg")[0].split(/s+/)[0..-2].collect{|v| v.to_f}
      {:one_minute => vals[0], :five_minute => vals[1], :fifteen_minue => vals[2]}        
    end

    #.......................................................................................................
    def diskstats
      LinuxCommands.file_system_mount_to_device.inject([]) |stats, mount|
        stat_row = LinuxCommands.cat("/proc/diskstats").select {|row| /#{mount[:device].split("/").last}/.match(row)}.first
        unless stat_row.nil?
          stat_vals = stat_row.split(/\s+/)
          sector_size = LinuxCommands.sector_size
          stats.push({:mount => mount[:mount], 
                      :stats => {:reads => stat_vals[4], :merged_reads => stat_vals[5], :kb_read=> stat_vals[6] * sector_size, :time_reading => stat_vals[7],
                                 :writes => stat_vals[8], :kb_written=> stat_vals[9]  * sector_size, :time_writing => stat_vals[10]}})
        else
          stats
        end        
      end
    end

    #......................................................................................................
    def cpu_count
      LinuxCommands.cat("/proc/cpuinfo").inject(0) {|n, r| /^processor/.match(r) ? n + 1 : n}
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
