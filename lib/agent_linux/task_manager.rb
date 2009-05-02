############################################################################################################
class TaskManager

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    def performace_collector
      @@performace_collector
    end
    
    #.........................................................................................................
    def did_connect(client_connection)
      AgentXmpp.log_info "PerformanceCollector.did_connect"
    end

    #.........................................................................................................
    def performance_collection(period)
      @@performace_collector = self.periodic_task(period) do 
        self.performance_commands_class.cpu_stats(period)
      end
    end

    #.........................................................................................................
    def performance_commands_class
      @@command_class ||= eval("#{`uname -s`.chop}PerformanceCommands")
    end
    
    #.........................................................................................................
    def periodic_task(period)
      collector = lambda do
        while true
          yield
          sleep(period)
        end
      end
      EventMachine.defer(collector)
    end
  
  ###------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# SystemCommands
end
