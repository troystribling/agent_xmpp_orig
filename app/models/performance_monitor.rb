############################################################################################################
class PerformanceMonitor

  #---------------------------------------------------------------------------------------------------------
  include DataMapper::Resource
  #---------------------------------------------------------------------------------------------------------
  
  ####------------------------------------------------------------------------------------------------------
  property :id,                 Serial
  property :monitor,            String
  property :monitor_class,      String
  property :monitor_object,     String
  property :value,              Float
  property :created_at,         Time

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def query_gte_time(args)
      args = [args] unless args.kind_of?(Array)
      args.each do |monitor| 
        class_eval <<-do_eval
          def self.#{monitor.to_s}_gte_time(interval)
            records = self.all(:created_at.gte => interval, :monitor => "#{monitor.to_s}", :order => [:created_at.asc]).to_a
            extract_pm(records)
          end
        do_eval
      end
    end
  
    #.........................................................................................................
    def query_gte_time_for_object(args)
      args = [args] unless args.kind_of?(Array)
      args.each do |monitor| 
        class_eval <<-do_eval
          def self.#{monitor.to_s}_gte_time_for_object(interval, obj)
            records = self.all(:created_at.gte => interval, :monitor => "#{monitor.to_s}", :monitor_object => obj, :order => [:created_at.asc]).to_a
            extract_pm(records)
          end
        do_eval
      end
    end
    
  ####------------------------------------------------------------------------------------------------------
  private
  
    def extract_pm(records)
      start_time = records.first.created_at
      time_series = records.collect do |pm|
        {:value => pm.value, :time => pm.created_at - start_time}
      end
      time_series.count.eql?(1) ? time_series.first : time_series
    end
  
  end
  ####------------------------------------------------------------------------------------------------------
  
  ####------------------------------------------------------------------------------------------------------
  query_gte_time [:cpu_total, :processes, :procs_running, :procs_blocked, :ctxt, :one_minute_load] 
  query_gte_time [:mem_used_total, :mem_used_process, :cached_total, :swap_used, :swap_free, :pgin, :pgout, 
    :pswpin, :pswpout, :pgmajfault] 

  query_gte_time_for_object [:recv_kbytes, :trans_kbytes, :recv_errors, :trans_errrors, :recv_drop, :trans_drop]
  query_gte_time_for_object [:reads, :kb_read, :writes, :kb_written, :time_reading, :time_writting, :busy_reading, 
    :busy_writing,:service_time_reading, :srvice_time_writing, :service_time]
  
end
