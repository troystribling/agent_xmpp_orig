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
            extract_pm(self.all(:created_at.gte => interval, :monitor => "#{monitor.to_s}", :order => [:created_at.asc]).to_a)
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
           extract_pm(self.all(:created_at.gte => interval, :monitor => "#{monitor.to_s}", :monitor_object => obj, :order => [:created_at.asc]).to_a)
          end
        do_eval
      end
    end
    
  ####------------------------------------------------------------------------------------------------------
  private
  
    def extract_pm(records)
      time_series = unless records.empty?
                      start_time = records.first.created_at
                      records.collect do |pm|
                        {:value => pm.value, :time => pm.created_at - start_time}
                      end 
                    else
                      records
                    end
      time_series.count.eql?(1) ? time_series.first : time_series
    end
  
  end
  ####------------------------------------------------------------------------------------------------------
  
  ####------------------------------------------------------------------------------------------------------
  query_gte_time LinuxPerformanceMonitors.monitors_for_class(:cpu) 
  query_gte_time LinuxPerformanceMonitors.monitors_for_class(:memory) 
  query_gte_time_for_object LinuxPerformanceMonitors.monitors_for_class(:network)
  query_gte_time_for_object LinuxPerformanceMonitors.monitors_for_class(:storage)
  
end
