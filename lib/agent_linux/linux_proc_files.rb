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
        stat_file = {:cpu => cpu, :ctxt => mon_val(rows[2 + ncpus]), :processes => mon_val(rows[4 + ncpus]), 
                     :procs_running => mon_val(rows[5 + ncpus]), :procs_blocked => mon_val(rows[6 + ncpus])}
        yield stat_file        
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
      row.split(/\s+/).last.to_f
    end

  ###--------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxProcFiles
end
