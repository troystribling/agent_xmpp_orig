##############################################################################################################
LinuxPerformanceMonitors.add_monitors do |monitors|

  #### cpu monitors
  monitors.add_class(:cpu) do |monitor|
    monitor.add :cpu_total,           "%",    "total cpu consumed"
    monitor.add :user,                "%",    "cpu consumed by user processes"
    monitor.add :nice,                "%",    "cpu consumed by nice user processes"
    monitor.add :system,              "%",    "cpu consumed by system processes"
    monitor.add :idle,                "%",    "cpu idle"
    monitor.add :iowait,              "%",    "cpu consumed waiting on IO"
    monitor.add :irq,                 "%",    "cpu consumed servicing hardware interrupts"
    monitor.add :softirq,             "%",    "cpu consumed servicing software interrupts"
    monitor.add :steal,               "%",    "cpu consumed by virtual host hypervisor"
    monitor.add :guest,               "%",    "cpu consumed by hosted guests"
    monitor.add :ctxt,                "1/s",  "context switches per second"
    monitor.add :processes,           "1/s",  "new processes creation rate"
    monitor.add :procs_running,       "",     "running processes"
    monitor.add :one_minute_load,     "",     "one minute load average"
    monitor.add :five_minute_load,    "",     "five minute load average"
    monitor.add :fifteen_minute_load, "",     "fifteen minute load average"
  end

  #### memory monitors
  monitors.add_class(:memory) do |monitor|
    monitor.add :mem_total,         "GB",   "total amount of memory consumed by all activities"
    monitor.add :mem_free,          "GB",   "free memory"
    monitor.add :buffers,           "GB",   "memory used by buffer cache"
    monitor.add :cached,            "GB",   "memory used by page cache"
    monitor.add :swap_cached,       "GB",   "memory used by swap cache"
    monitor.add :cached_total,      "GB",   "total memory used by all caches"
    monitor.add :swap_total,        "GB",   "size of swap file"
    monitor.add :swap_free,         "GB",   "free space in swap file"
    monitor.add :swap_used,         "GB",   "space used in swap file"
    monitor.add :mem_used_total,    "GB",   "total memory used by cache and processes"
    monitor.add :meme_used_process, "GB",   "total memory used by processes"
    monitor.add :pgin,              "KB/s", "total memory paged in"
    monitor.add :pgout,             "KB/s", "total memory paged out"
    monitor.add :pswpin,            "KB/s", "total memory paged in from swap file"
    monitor.add :pswpout,           "KB/s", "total memory paged out to swap file"
    monitor.add :pgfault,           "1/s",  "total page faults(soft and major)"
    monitor.add :pgmajfault,        "1/s",  "total major page faults"
  end

  #### storage monitors
  monitors.add_class(:storage) do |monitor|
    monitor.add :file_system_used,      "1", "total storage used by mount point relative to size"
    monitor.add :file_system_size,      "MB"          total storage allocated to mount point
    monitor.add :reads,                 "1/s "   number of reads at mount point
    monitor.add :merged_reads ,         "1/s"    number of merged/aggregated reads at mount 
                                                                                point
    monitor.add :kb_read,               "KB/s"        KB read at mount point
    monitor.add :busy_reading,          "%"     amount of time spent reading from mount 
                                                                                point
    monitor.add :service_time_reading,  "ms"          average time required to service a read 
                                                                                from mount point
    monitor.add :writes,                "1/s"    number of writes at mount point
    monitor.add :kb_written ,           "KB/s"        KB written at mount point
    monitor.add :busy_writing,          "%"     amount of time spent busy_writing to mount 
                                                                                point
    monitor.add :service_time_writing,  "ms"          average time required to service a write 
                                                                                to mount point
    monitor.add :service_time,          "ms"          average time required to service a read or 
                                                                            write request at mount point
  end
                                                                          
  #### network monitors
  monitors.add_class(:network) do |monitor|  
    monitor.add :recv_kbytes,     "KB/s"        kilobytes received at interface
    monitor.add :recv_packets,    "1/s"    packets received at interface
    monitor.add :recv_errors,     "1/s"    errors received at interface
    monitor.add :recv_drop,       "1/s"    packets dropped at interface
    monitor.add :trans_kbytes,    "KB/s"        kilobytes transmitted at interface
    monitor.add :trans_packets,   "1/s"    packets transmitted at interface
    monitor.add :trans_errors,    "1/s"    errors transmitted at interface
    monitor.add :trans_drop,      "1/s"    packets transmitted at interface
  end
