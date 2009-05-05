############################################################################################################
class LinuxProcFiles

  ###------------------------------------------------------------------------------------------------------
  class << self
    
    #.......................................................................................................
    def stat
      cat("/proc/stat") do |rows|
p rows        
        cpu_row = rows[0].split(/s+/)[1..-1].collect{|c| c/100.0}
        cpu = {:user => cpu_row[1], :nice => cpu_row[2], :system => cpu_row[3], :idle => cpu_row[4], :iowait => cpu_row[5],
               :irq => cpu_row[6], :softirq => cpu_row[7], :steal => cpu_row[8], :guest => cpu_row[9], 
               :total => cpu_row[1] + cpu_row[2] + cpu_row[3] + cpu_row[5] + cpu_row[6] + cpu_row[7] + cpu_row[8] + cpu_row[9] - cpu_row[4]} 
        stat_file = {:cpu => cpu, :ctxt => mon_val(rows[4]), :processes => mon_val(rows[6]), :procs_running => mon_val(rows[7]), 
                     :procs_blocked => mon_val(rows[8])}
        yield stat_file        
      end
    end

    #......................................................................................................
    def cat(file_name)
      yield `cat #{file_name}`.split("\n")
    end  
      
    #........................................................................................................
    def mon_val(row)
      rows.split(/s+/)[1]
    end

  ###--------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxProcFiles
end
