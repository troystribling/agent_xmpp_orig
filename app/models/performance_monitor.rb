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
      class_eval <<-do_eval
        def self.#{args[:monitor].to_s}_gte_time(interval)
          time_series = self.all(:created_at.gte => interval, :monitor_class => "#{args[:monitor_class].to_s}", :monitor => "#{args[:monitor].to_s}", :order => [:created_at.desc]).to_a.collect do |pm|
            {"#{args[:monitor]}" => pm.value, :created_at => pm.created_at}
          end
          time_series.count.eql?(1) ? time_series.first : time_series
        end
      do_eval
    end
  
  end
  ####------------------------------------------------------------------------------------------------------
  
  ####------------------------------------------------------------------------------------------------------
  query_gte_time :monitor_class => :cpu, :monitor => :cpu_total 
  
end
