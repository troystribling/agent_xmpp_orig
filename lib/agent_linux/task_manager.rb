############################################################################################################
class TaskManager
 
  #.........................................................................................................
  @last_collection = {}
  @collection_period = {}
  #.........................................................................................................

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    attr_accessor :last_collection, :collection_period
    #.........................................................................................................

    #.........................................................................................................
    # tasks
    #.........................................................................................................
    def performance_collection(period)
      periodic_task(period, :performance_collection) do
        performance_class.cpu
        performance_class.memory
        performance_class.loadavg
        performance_class.storage
        performance_class.net
      end
    end
 
    #.........................................................................................................
    def trim_performance_data(period)
      periodic_task(period, :trim_performance_data) do
        PerformanceMonitor.all(:created_at.lt => Time.now - period).destroy!
      end
    end
 
  ####.....................................................................................................
  private

    #.........................................................................................................
    def periodic_task(period, method)
      AgentXmpp.logger.info "TaskManager.#{method.to_s} with period #{period}s"
      last_collection[method] = Time.now
      collection_period[method] = period
      EventMachine::PeriodicTimer.new(period) do
        start_collection = Time.now
        AgentXmpp.logger.debug "TaskManager.#{method.to_s} last collection #{(start_collection - last_collection[method]).to_f}s ago"
        AgentXmpp.logger.debug "TaskManager.#{method.to_s} starting #{start_collection}"
        yield
        completed_collection = Time.now
        AgentXmpp.logger.debug "TaskManager.#{method.to_s} stopping #{completed_collection} required #{(completed_collection - start_collection).to_f}s"
        last_collection[method] = completed_collection
      end
    end

    #.........................................................................................................
    def performance_class
      @@performance_class ||= eval("#{`uname -s`.chop}Performance")
    end
    
    #.........................................................................................................
    # xmpp connection delegate methods
    #.........................................................................................................
    def did_connect(client_connection)
      AgentXmpp.logger.info "TaskManager.did_connect"
    end
    
  ###------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# SystemCommands
end
