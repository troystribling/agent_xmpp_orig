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
      vals = LinuxCommands.cat("/proc/meminfo").collect{|v| (mon_val(v) / 1024).precision}
      {:mem_total     => vals[0],
       :mem_free      => vals[1],
       :buffers       => vals[2],
       :cached        => vals[3],
       :swp_cached    => vals[4],
       :active        => vals[5],
       :inactive      => vals[6],
       :swap_total    => vals[11],
       :swap_free     => vals[12],
       :swap_used     => (vals[11] - vals[12]).precision,
       :total_cached  => (vals[2] + vals[3] + vals[4]).precision,
       :total_used    => (vals[0] - vals[1]).precision,
       :process_used  => (vals[0] - vals[1] - vals[2] - vals[3] - vals[4]).precision}
    end

    #.......................................................................................................
    def vmstat
      rows = LinuxCommands.cat("/proc/vmstat").collect{|v| mon_val(v)}
      page_size = LinuxCommands.get_memory_page_size
      {:pgin => rows[15] * page_size, :pgin => rows[16] * page_size,
       :pswpin => rows[17] * page_size, :pswpout => rows[18] * page_size,
       :pgfault => rows[26], :pgmajfault => rows[27]}         
    end

    #.......................................................................................................
    def loadavg
      vals = LinuxCommands.cat("/proc/loadavg")[0].split(/\s+/)[0..-3].collect{|v| v.to_f}
      {:one_minute => vals[0], :five_minute => vals[1], :fifteen_minue => vals[2]}        
    end

    #.......................................................................................................
    def net_dev
      LinuxCommands.cat("/proc/net/dev").select{|r| /eth\d/.match(r)}.collect do |r|
        row = r.strip.split(/\s+/)
        vals = row[1..-1].collect{|v| v.to_f}
        {:if => row[0].chomp(':'), 
          :stat => {:recv_bytes => (vals[0] / 1024**2).precision, :recv_packets => vals[1], :recv_errors => vals[2], :recv_drop => vals[3],
                    :trans_bytes => (vals[8] / 1024**2).precision, :trans_packets => vals[9], :trans_errrors => vals[10], :trans_drop => vals[11]}}       
      end
    end

    #.......................................................................................................
    def diskstats
      LinuxCommands.file_system_mount_to_device.inject([]) do |stats, mount|
        stat_row = LinuxCommands.cat("/proc/diskstats").select{|row| /#{mount[:device].split("/").last}/.match(row)}.first
        unless stat_row.nil?
          stat_vals = stat_row.strip.split(/\s+/).collect{|v| v.to_f}
          sector_size = LinuxCommands.sector_size(mount[:device])
          stats.push({:mount => mount[:mount], 
                      :stats => {:reads => stat_vals[3], :merged_reads => stat_vals[4], :kb_read=> stat_vals[5] * sector_size, :time_reading => stat_vals[6],
                                 :writes => stat_vals[7], :kb_written=> stat_vals[8]  * sector_size, :time_writing => stat_vals[9]}})
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
