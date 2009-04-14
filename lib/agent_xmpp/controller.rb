##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Controller

    #---------------------------------------------------------------------------------------------------------
    attr_reader :format, :params, :connection
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize
    end
 
    #---------------------------------------------------------------------------------------------------------
    # actions
    #.........................................................................................................
    def execute
      AgentXmpp::logger.info "ACTION: AgentXmpp::Controller\#execute"
    end

    #.........................................................................................................
    def prev
      AgentXmpp::logger.info "ACTION: AgentXmpp::Controller\#prev"
    end

    #.........................................................................................................
    def next
      AgentXmpp::logger.info "ACTION: AgentXmpp::Controller\#next"
    end
    
    #.........................................................................................................
    def complete
      AgentXmpp::logger.info "ACTION: AgentXmpp::Controller\#complete"
    end

    #.........................................................................................................
    def cancel
      AgentXmpp::logger.info "ACTION: AgentXmpp::Controller\#cancel"
    end
    
    #---------------------------------------------------------------------------------------------------------
    # handle request
    #.........................................................................................................
    def handle_request(connection, action, params)
      @params = params
      @connection = connection
      @format = Format.new(params[:xmlns])
      self.send(action)
    end

    #.........................................................................................................
    def result_for(&blk)
      @result_for_blk = blk
    end

    #.........................................................................................................
    def respond_to(&blk)
      View.send(:define_method, :respond_to, &blk)
      View.send(:define_method, :result_callback) do |result|
        self.connection.send(self.add_payload_to_container(self.respond_to(result)))
      end
      EventMachine.defer(@result_for_blk, View.new(self.connection, self.format, self.params).method(:result_callback).to_proc)
    end
    
    
  #### Controller
  end

#### AgentXmpp
end

