############################################################################################################
class LinuxPerformance

  #.........................................................................................................
  @last_vals = {}
  @last_time = {}

  ###------------------------------------------------------------------------------------------------------
  class << self
        
    #.........................................................................................................
    def stat      
      LinuxProcFiles.stat do |data|
        created_at = Time.now  
        unless @last_vals[:stat].nil?
          dt = (created_at - @last_time[:stat]).to_f   
          data[:cpu].each_pair do |mon, val|
            dv = ((val - @last_vals[:stat][:cpu][mon])/dt).precision
            PerformanceMonitor.new(:monitor => mon.to_s, :value => dv, :monitor_class => "cpu", :created_at => created_at).save unless dv < 0
          end
          dc = ((data[:ctxt] - @last_vals[:stat][:ctxt])/dt).precision
          PerformanceMonitor.new(:monitor => "ctxt", :value => dc, :monitor_class => "cpu", :created_at => created_at).save unless dc < 0
          dp = ((data[:processes] - @last_vals[:stat][:processes])/dt).precision
          PerformanceMonitor.new(:monitor => "processes", :value => dp, :monitor_class => "cpu", :created_at => created_at).save unless dp < 0
          PerformanceMonitor.new(:monitor => "procs_running", :value => @last_vals[:stat][:procs_running].to_s, :monitor_class => "cpu", :created_at => created_at).save
          PerformanceMonitor.new(:monitor => "procs_blocked", :value => @last_vals[:stat][:procs_blocked].to_s, :monitor_class => "cpu", :created_at => created_at).save
        end
        @last_vals[:stat] = data
        @last_time[:stat] = created_at
      end
    end

  ###------------------------------------------------------------------------------------------------------
  end
         
############################################################################################################
# LinuxCommands
end
