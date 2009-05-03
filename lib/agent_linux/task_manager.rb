############################################################################################################
class TaskManager

  ####------------------------------------------------------------------------------------------------------
  class << self
    
    #.........................................................................................................
    @@tasks = {}
    @@tasks_mutex = Mutex.new
    
    #.........................................................................................................
    # task instaces
    #.........................................................................................................
    def performance_collection(config)
      task = periodic_defered_task(:performance_collection, config[:period]) do 
        commands_class.cpu_stats(config)
      end
      add_task(:performance_collection, {:args => config, :task => task, :missed_ping_after => 2 * config[:period]})
    end

    #.........................................................................................................
    # task managment
    #.........................................................................................................
    def add_task(name, data)
      @@tasks_mutex.synchronize do
        @@tasks[name] = data.merge(:ping => Time.now)
      end
    end

    #.........................................................................................................
    def remove_task(name)
      @@tasks_mutex.synchronize do
        @@tasks.delete(name)
      end
    end

    #.........................................................................................................
    def ping(name)
      @@tasks_mutex.synchronize do
        @@tasks[name][:ping] = Time.now
      end
    end
        
    #.........................................................................................................
    def reaper(period)
      periodic_timer(period) do 
        @@tasks_mutex.synchronize do
          @@tasks.each_pair do |name, data|
            last_ping = (Time.now - data[:ping]).to_f.to_i
            if last_ping > data[:missed_ping_after]
              AgentXmpp.log_warn "TaskManager.reaper: missed #{name} ping for #{last_ping} seconds"
            end
          end
        end
      end
    end

    #.........................................................................................................
    def commands_class
      @@command_class ||= eval("#{`uname -s`.chop}Commands")
    end
    
    #.........................................................................................................
    # task types
    #.........................................................................................................
    def periodic_defered_task(name, period)
      collector = lambda do
        while true
          yield
          ping(name)
          sleep(period)
        end
      end
      EventMachine.defer(collector)
    end

    #.........................................................................................................
    def periodic_timer(period)
      EventMachine::PeriodicTimer.new(period) do
        yield
      end
    end
    
    #.........................................................................................................
    # xmpp connection delegate methods
    #.........................................................................................................
    def did_connect(client_connection)
      AgentXmpp.log_info "TaskManager.did_connect"
    end
    
  ###------------------------------------------------------------------------------------------------------
  end
   
############################################################################################################
# SystemCommands
end
