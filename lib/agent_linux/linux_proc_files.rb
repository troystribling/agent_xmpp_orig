############################################################################################################
class LinuxProcFiles

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.......................................................................................................
    def uptime
      vals = cat("/proc/uptime")[0].split(/\s+/).collect{|v| v.to_f}
      {:booted_on => Time.now - vals[0], :up_time => time_interval(vals[0]), 
       :busy => (vals[0] - vals[1]) / vals[0], :idle => vals[1] / vals[0]}    
    end    
    
    #.......................................................................................................
    def stat
      rows = cat("/proc/stat")
      cpu_row = rows[0].split(/\s+/)[1..-1].collect{|c| c.to_f/100.0}
      cpu = {:user => cpu_row[0], :nice     => cpu_row[1], :system  => cpu_row[2], :idle  => cpu_row[3], :iowait => cpu_row[4],
             :irq =>  cpu_row[5], :softirq  => cpu_row[6], :steal   => cpu_row[7], :guest => cpu_row[8], 
             :cpu_total => cpu_row[0] + cpu_row[1] + cpu_row[2] + cpu_row[4] + cpu_row[5] + cpu_row[6] + cpu_row[7] + cpu_row[8]} 
      ncpus = cpu_count   
      {:cpu       => cpu, 
       :cpu_procs => {:ctxt          => mon_val(rows[2 + ncpus]), :processes      => mon_val(rows[4 + ncpus])}, 
       :procs     => {:procs_running => mon_val(rows[5 + ncpus]), :procs_blocked  => mon_val(rows[6 + ncpus])}}
    end

    #.......................................................................................................
    def meminfo
      vals = cat("/proc/meminfo").collect{|v| (mon_val(v) / (1024 * 1024)).precision}
      {:mem_total         => vals[0],  :mem_free    => vals[1],
       :buffers           => vals[2],  :cached      => vals[3],
       :swap_cached       => vals[4],  :swap_total  => vals[11],
       :swap_free         => vals[12], :swap_used   => (vals[11] - vals[12]).precision,
       :cached_total      => (vals[2] + vals[3] + vals[4]).precision,
       :mem_used_total    => (vals[0] - vals[1]).precision,
       :mem_used_process  => (vals[0] - vals[1] - vals[2] - vals[3] - vals[4]).precision}
    end

    #.......................................................................................................
    def vmstat
      rows = cat("/proc/vmstat").collect{|v| mon_val(v)}
      page_size = get_memory_page_size
      {:pgin    => (rows[15] * page_size).precision, :pgout      => (rows[16] * page_size).precision,
       :pswpin  => (rows[17] * page_size).precision, :pswpout    => (rows[18] * page_size).precision,
       :pgfault => rows[26],                         :pgmajfault => rows[27]}         
    end

    #.......................................................................................................
    def loadavg
      vals = cat("/proc/loadavg")[0].split(/\s+/)[0..-3].collect{|v| v.to_f}
      {:one_minute_load => vals[0], :five_minute_load => vals[1], :fifteen_minue_load => vals[2]}        
    end

    #.......................................................................................................
    def net_dev
      net_stat = cat("/proc/net/dev").select{|r| /eth\d/.match(r)}.collect do |r|
        row = r.strip.split(/\s+/)
        vals = row[1..-1].collect{|v| v.to_f}
        {:if => row[0].chomp(':'), 
         :vals => {:recv_kbytes   => (vals[0] / 1024).precision,  :recv_packets   => vals[1], 
                   :recv_errors => vals[2],                       :recv_drop  => vals[3],
                   :trans_kbytes  => (vals[8] / 1024).precision,  :trans_packets  => vals[9], 
                   :trans_errrors => vals[10],                    :trans_drop => vals[11]}}       
      end
      net_stat.push({:if => 'all', :vals => total_stats(net_stat, :vals)})
    end

    #.......................................................................................................
    def diskstats
      disk_stats = cat("/proc/diskstats").select{|row| /sd\D\s/.match(row)}.collect do |stat_row|
        stat_vals = stat_row.strip.split(/\s+/)
        sector_size = sector_size(stat_vals[2])
        {:device => stat_vals[2], 
         :vals => {:reads => stat_vals[3].to_f,   :merged_reads => stat_vals[4].to_f, :kb_read=> (stat_vals[5].to_f * sector_size).precision,                                 
                   :writes => stat_vals[7].to_f,  :kb_written=> (stat_vals[9].to_f  * sector_size).precision},
         :time_vals => {:time_reading => stat_vals[6].to_f, :time_writing => stat_vals[10].to_f}}
      end
      disk_stats.push({:device => 'all', :vals => total_stats(disk_stats, :vals), :time_vals => total_stats(disk_stats, :time_vals)})
    end

    #......................................................................................................
    def cpu_count
      cat("/proc/cpuinfo").inject(0) {|n, r| /^processor/.match(r) ? n + 1 : n}
    end  

  ####.....................................................................................................
  private
  
    #.......................................................................................................
    def total_stats(stats, hash_key)
      tot = {}
      stats.each do |val|
        val[hash_key].each_pair do |k, v|
          tot[k] ||= 0
          tot[k] +=v
        end 
      end
      tot
    end
  
    #.......................................................................................................
    def time_interval(interval)
      days = (interval/86400).truncate
      hours = ((interval - days * 86400) / 3600).truncate
      minutes = ((interval - hours * 3600 - days * 86400) / 60).truncate
      {:days => days, :hours => hours, :minutes => minutes}
    end

    #.......................................................................................................
    def mon_val(row)
      row.split(/\s+/)[1].to_f
    end

    #.......................................................................................................
    def get_memory_page_size
      (`getconf PAGESIZE`.chop.to_f/1024).precision
    end
    
    #.......................................................................................................
    def cat(file_name)
      `cat #{file_name}`.split("\n")
    end  
    
    #.........................................................................................................
    def sector_size(device = nil)
      (512.0 / 1024.0)
    end

  ###--------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxProcFiles
end
