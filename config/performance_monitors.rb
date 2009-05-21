##############################################################################################################
LinuxPerformanceMonitors.add_monitors do |monitors|

  #### cpu monitors
  monitors.add_class(:cpu) do |monitor|
    monitor.add :cpu_total,           "%",    "total"
    monitor.add :user,                "%",    "user process"
    monitor.add :nice,                "%",    "nice user process"
    monitor.add :system,              "%",    "system processe"
    monitor.add :idle,                "%",    "idle"
    monitor.add :iowait,              "%",    "IO wait"
    monitor.add :irq,                 "%",    "hardware interrupt servicing"
    monitor.add :softirq,             "%",    "software interrupt servicing"
    monitor.add :steal,               "%",    "virtual host hypervisor"
    monitor.add :guest,               "%",    "hosted guests"
    monitor.add :ctxt,                "1/s",  "context switching rate"
    monitor.add :processes,           "1/s",  "processes creation rate"
    monitor.add :procs_running,       "",     "running processes"
    monitor.add :one_minute_load,     "",     "one minute load average"
    monitor.add :five_minute_load,    "",     "five minute load average"
    monitor.add :fifteen_minute_load, "",     "fifteen minute load average"
  end

  #### memory monitors
  monitors.add_class(:memory) do |monitor|
    monitor.add :mem_total,         "GB",   "installed"
    monitor.add :mem_free,          "GB",   "free"
    monitor.add :buffers,           "GB",   "buffer cache"
    monitor.add :cached,            "GB",   "page cache"
    monitor.add :swap_cached,       "GB",   "swap cache"
    monitor.add :cached_total,      "GB",   "total cache"
    monitor.add :swap_total,        "GB",   "swap file size"
    monitor.add :swap_free,         "GB",   "free swap"
    monitor.add :swap_used,         "GB",   "swap used"
    monitor.add :mem_used_total,    "GB",   "total used by cache and processes"
    monitor.add :meme_used_process, "GB",   "total used by processes"
    monitor.add :pgin,              "KB/s", "total page in rate"
    monitor.add :pgout,             "KB/s", "total page out rate"
    monitor.add :pswpin,            "KB/s", "swap in rate"
    monitor.add :pswpout,           "KB/s", "swap out rate"
    monitor.add :pgfault,           "1/s",  "total page fault rate"
    monitor.add :pgmajfault,        "1/s",  "major page fault rate"
  end

  #### storage monitors
  monitors.add_class(:storage) do |monitor|
    monitor.add :file_system_used,      "%",    "file system used"
    monitor.add :file_system_size,      "MB",   "file system size"
    monitor.add :reads,                 "1/s",  "read rate"
    monitor.add :merged_reads ,         "1/s",  "merged read rate"
    monitor.add :kb_read,               "KB/s", "KB read rate"
    monitor.add :busy_reading,          "%",    "time spent reading"
    monitor.add :service_time_reading,  "ms",   "read service time"
    monitor.add :writes,                "1/s",  "write rate"
    monitor.add :kb_written ,           "KB/s", "KB write rate"
    monitor.add :busy_writing,          "%",    "time spent writing"
    monitor.add :service_time_writing,  "ms",   "write service time"
    monitor.add :service_time,          "ms",   "total service time"
  end
                                                                          
  #### network monitors
  monitors.add_class(:network) do |monitor|  
    monitor.add :recv_kbytes,     "KB/s", "KB receive rate"
    monitor.add :recv_packets,    "1/s",  "packet receive rate"
    monitor.add :recv_errors,     "1/s",  "error receive rate"
    monitor.add :recv_drop,       "1/s",  "received packet drop rate"
    monitor.add :trans_kbytes,    "KB/s", "KB transmit rate"
    monitor.add :trans_packets,   "1/s",  "packet transmit rate"
    monitor.add :trans_errors,    "1/s",  "error transmit rate"
    monitor.add :trans_drop,      "1/s",  "transmit packet drop rate"
  end
  
end
