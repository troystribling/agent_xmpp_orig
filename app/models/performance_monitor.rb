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
            start_time = records.first.created_at
            time_series = records.collect do |pm|
              {"#{monitor}" => pm.value, :time => pm.created_at - start_time}
            end
            time_series.count.eql?(1) ? time_series.first : time_series
          end
        do_eval
      end
    end
  
  end
  ####------------------------------------------------------------------------------------------------------
  
  ####------------------------------------------------------------------------------------------------------
  query_gte_time :cpu_total 
  
end
